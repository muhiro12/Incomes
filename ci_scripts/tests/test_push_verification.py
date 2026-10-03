"""Isolated tests for the Incomes pre-push scope/evidence pilot.

Fixtures are synthetic evidence, not successful Incomes builds or secret scans.
No Git push or network access is used.
"""
from __future__ import annotations

import copy
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

CHECKER = Path(__file__).resolve().parents[1] / "tasks/check_push_verification.py"
ZERO = "0" * 40


class PushVerificationTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name).resolve()
        self.git("init", "-q")
        self.git("config", "user.name", "Fixture")
        self.git("config", "user.email", "fixture@example.invalid")
        self.write("Sources/value.swift", "let value = 1\n")
        self.commit("Initial")
        self.base = self.git("rev-parse", "HEAD")
        self.write("Sources/value.swift", "let value = 2\n")
        self.commit("Change value")
        self.tip = self.git("rev-parse", "HEAD")
        self.store = self.root / ".git/push-verification"
        self.store.mkdir()
        self.update = self.tuple(self.tip, "refs/heads/main", self.base)
        self.receipt = self.make_receipt([self.update])
        self.save()

    def tearDown(self):
        self.temporary.cleanup()

    def git(self, *args):
        q = subprocess.run(["git", *args], cwd=self.root, capture_output=True, text=True,
                           env={**os.environ, "GIT_OPTIONAL_LOCKS": "0"})
        self.assertEqual(q.returncode, 0, q.stderr)
        return q.stdout.strip()

    def write(self, path, value):
        p = self.root / path
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(value)

    def commit(self, message):
        self.git("add", ".")
        self.git("commit", "-qm", message)

    def tuple(self, oid, ref, old):
        return {"local_ref": oid, "local_oid": oid, "remote_ref": ref, "remote_oid": old}

    def record(self, name, oid=None):
        oid = oid or self.tip
        directory = self.store / name
        directory.mkdir(exist_ok=True)
        log = directory / "output.log"
        log.write_text("Synthetic fixture output; not product verification.\n")
        source = {"head": oid, "tree": self.git("rev-parse", oid + "^{tree}"),
                  "clean": True, "status_sha256": hashlib.sha256(b"").hexdigest()}
        result = {"schema_version": 1,
                  "source": {"before": source, "after": source, "stable_clean_snapshot": True},
                  "environment": {"fixture": "isolated"},
                  "verification": {"ran": True, "argv": ["fixture-only"], "exit_code": 0, "status": "passed"},
                  "diagnostics": {"complete_captured_output": True, "warning_count": 0,
                                  "error_count": 0, "warnings": [], "errors": []},
                  "tests": {"executed": 1, "failed": 0, "skipped": 0},
                  "artifacts": [{"path": "output.log", "sha256": hashlib.sha256(log.read_bytes()).hexdigest()}],
                  "evidence_errors": []}
        (directory / "result.json").write_text(json.dumps(result))
        return name + "/result.json"

    def make_receipt(self, updates):
        commits = set()
        quality = {}
        for item in updates:
            args = ["rev-list", item["local_oid"]]
            if item["remote_oid"] != ZERO:
                args.extend(["--not", item["remote_oid"]])
            commits.update(self.git(*args).splitlines())
            oid = item["local_oid"]
            path = self.record("quality-" + oid, oid)
            quality[oid] = {"tree": self.git("rev-parse", oid + "^{tree}"),
                            "environment": {"fixture": "isolated"},
                            "checks": {kind: {"status": "passed", "evidence": path,
                                             "scope": "synthetic fixture", "skipped": 0}
                                       for kind in ["build", "tests", "lint"]}}
            quality[oid]["checks"]["diagnostics"] = {
                "status": "passed", "evidence": [path], "scope": "all fixture records"}
        review = self.store / "contextual-review.txt"
        review.write_text("Synthetic review of all listed fixture commits.\n")
        scan_report = self.store / "scan-report.json"
        scan_report.write_text("[]\n")
        return {"schema_version": 1, "common_git_dir": str(self.root / ".git"),
                "destination": {"remote_name": "origin", "location_sha256": hashlib.sha256(b"fixture://private").hexdigest()},
                "updates": sorted(updates, key=lambda item: item["remote_ref"]), "quality": quality,
                "publication": {"commits": sorted(commits), "uninspected": [],
                    "mechanical": {"status": "passed", "scanner": "gitleaks", "scanner_version": "synthetic",
                                   "commits": sorted(commits), "evidence": self.record("scanner"),
                                   "report": "scan-report.json", "sha256": hashlib.sha256(scan_report.read_bytes()).hexdigest()},
                    "contextual": {"status": "passed", "commits": sorted(commits),
                                   "report": "contextual-review.txt", "sha256": hashlib.sha256(review.read_bytes()).hexdigest()}}}

    def save(self):
        (self.store / "receipt.json").write_text(json.dumps(self.receipt))

    def run_check(self, updates=None, remote="fixture://private"):
        updates = updates if updates is not None else [self.update]
        lines = "".join(" ".join(item[key] for key in ["local_ref", "local_oid", "remote_ref", "remote_oid"]) + "\n"
                        for item in updates)
        return subprocess.run(["python3", str(CHECKER), "origin", remote], cwd=self.root,
                              input=lines, capture_output=True, text=True)

    def assert_rejected(self, phrase, updates=None, remote="fixture://private"):
        self.save()
        result = self.run_check(updates, remote)
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn(phrase, result.stderr)

    def test_matching_complete_synthetic_evidence(self):
        q = self.run_check()
        self.assertEqual(q.returncode, 0, q.stdout + q.stderr)
        self.assertIn("not independently proved", q.stdout)

    def test_missing_receipt_rejects(self):
        (self.store / "receipt.json").unlink()
        self.assertEqual(self.run_check().returncode, 1)

    def test_destination_mismatch_rejects(self):
        self.assert_rejected("destination", remote="fixture://different")

    def test_sha_ref_and_base_mismatch_reject(self):
        for key, value in [("local_oid", self.base), ("remote_ref", "refs/heads/other"), ("remote_oid", ZERO)]:
            with self.subTest(key=key):
                update = dict(self.update)
                update[key] = value
                self.assert_rejected("source SHA, refs", [update])

    def test_dirty_separate_work_does_not_replace_committed_snapshot(self):
        self.write("Sources/value.swift", "uncommitted separate work\n")
        self.write("untracked-note.txt", "other task\n")
        self.assertEqual(self.run_check().returncode, 0)
        record_path = self.store / self.receipt["quality"][self.tip]["checks"]["build"]["evidence"]
        record = json.loads(record_path.read_text())
        record["source"]["stable_clean_snapshot"] = False
        record_path.write_text(json.dumps(record))
        self.assert_rejected("stable clean")

    def test_commit_after_verification_rejects(self):
        self.write("Sources/value.swift", "let value = 3\n")
        self.commit("Later implementation")
        new = self.git("rev-parse", "HEAD")
        self.assert_rejected("source SHA, refs", [self.tuple(new, "refs/heads/main", self.base)])

    def test_multiple_refs_require_all_quality_and_history(self):
        updates = [self.update, self.tuple(self.base, "refs/heads/secondary", ZERO)]
        self.receipt = self.make_receipt(updates)
        self.save()
        self.assertEqual(self.run_check(updates).returncode, 0)
        del self.receipt["quality"][self.base]
        self.assert_rejected("quality evidence", updates)

    def test_new_branch_requires_full_reachable_history(self):
        update = self.tuple(self.tip, "refs/heads/new", ZERO)
        self.receipt = self.make_receipt([update])
        self.save()
        self.assertEqual(self.run_check([update]).returncode, 0)
        self.receipt["publication"]["commits"] = [self.tip]
        self.assert_rejected("Outgoing history", [update])

    def test_amend_same_tree_requires_new_history_review(self):
        self.git("commit", "--amend", "-qm", "Changed metadata")
        amended = self.git("rev-parse", "HEAD")
        update = self.tuple(amended, "refs/heads/main", self.base)
        self.receipt["updates"] = [update]
        self.receipt["quality"][amended] = self.receipt["quality"].pop(self.tip)
        self.assert_rejected("Outgoing history", [update])

    def test_docs_only_reuse_and_code_change_rejection(self):
        original_record = self.receipt["quality"][self.tip]["checks"]["build"]["evidence"]
        old = self.tip
        self.write("README.md", "Only prose changed\n")
        self.commit("Explain usage")
        doc_tip = self.git("rev-parse", "HEAD")
        update = self.tuple(doc_tip, "refs/heads/main", self.base)
        self.receipt = self.make_receipt([update])
        checks = self.receipt["quality"][doc_tip]["checks"]
        for kind in ["build", "tests", "lint"]:
            checks[kind].update(status="reused", evidence=original_record)
        checks["diagnostics"]["evidence"] = [original_record]
        self.save()
        self.assertEqual(self.run_check([update]).returncode, 0)
        self.write("Sources/value.swift", "let value = 4\n")
        self.commit("Change code")
        code_tip = self.git("rev-parse", "HEAD")
        update = self.tuple(code_tip, "refs/heads/main", self.base)
        self.receipt = self.make_receipt([update])
        checks = self.receipt["quality"][code_tip]["checks"]
        for kind in ["build", "tests", "lint"]:
            checks[kind].update(status="reused", evidence=original_record)
        checks["diagnostics"]["evidence"] = [original_record]
        self.assert_rejected("changed build/test/lint inputs", [update])

    def test_secret_added_then_removed_remains_in_review_scope(self):
        self.write("temporary-secret-fixture.txt", "SYNTHETIC_NOT_A_CREDENTIAL\n")
        self.commit("Add synthetic private example")
        added = self.git("rev-parse", "HEAD")
        (self.root / "temporary-secret-fixture.txt").unlink()
        self.commit("Remove synthetic example")
        removed = self.git("rev-parse", "HEAD")
        update = self.tuple(removed, "refs/heads/main", self.base)
        self.receipt = self.make_receipt([update])
        self.assertIn(added, self.receipt["publication"]["commits"])
        self.receipt["publication"]["commits"].remove(added)
        self.assert_rejected("Outgoing history", [update])

    def test_mechanical_and_contextual_reviews_cannot_be_omitted(self):
        for kind in ["mechanical", "contextual"]:
            with self.subTest(kind=kind):
                original = copy.deepcopy(self.receipt)
                self.receipt["publication"][kind]["status"] = "unavailable"
                self.assert_rejected("scan" if kind == "mechanical" else "Contextual")
                self.receipt = original

    def test_no_execution_errors_warnings_zero_tests_and_output_tamper_reject(self):
        path = self.store / self.receipt["quality"][self.tip]["checks"]["build"]["evidence"]
        original = json.loads(path.read_text())
        for changes in [{"verification": {"ran": False}}, {"verification": {"status": "failed", "exit_code": 7}},
                        {"diagnostics": {"warning_count": 1}}, {"tests": {"executed": 0}}]:
            with self.subTest(changes=changes):
                record = copy.deepcopy(original)
                for field, values in changes.items():
                    record[field].update(values)
                path.write_text(json.dumps(record))
                self.assertEqual(self.run_check().returncode, 1)
        path.write_text(json.dumps(original))
        (path.parent / "output.log").write_text("Changed output\n")
        self.assert_rejected("Tool output changed")

    def test_environment_change_and_uninspected_artifact_reject(self):
        self.receipt["quality"][self.tip]["environment"] = {"fixture": "changed toolchain"}
        self.assert_rejected("environments differ")
        self.receipt["quality"][self.tip]["environment"] = {"fixture": "isolated"}
        self.receipt["publication"]["uninspected"] = ["binary fixture"]
        self.assert_rejected("remain uninspected")

    def test_scanner_report_findings_and_tamper_are_not_ai_clean_claims(self):
        path = self.store / "scan-report.json"
        path.write_text('[{"RuleID":"synthetic-fixture"}]')
        self.receipt["publication"]["mechanical"]["sha256"] = hashlib.sha256(path.read_bytes()).hexdigest()
        self.assert_rejected("scanner report has findings")
        path.write_text("[]")
        self.assert_rejected("scanner report changed")

    def test_merge_side_history_is_included(self):
        self.git("checkout", "-qb", "side", self.base)
        self.write("side-history.txt", "side fixture\n")
        self.commit("Side history")
        side = self.git("rev-parse", "HEAD")
        self.git("checkout", "-q", "-")
        self.git("merge", "--no-ff", "-qm", "Merge side", "side")
        merged = self.git("rev-parse", "HEAD")
        update = self.tuple(merged, "refs/heads/main", self.base)
        self.receipt = self.make_receipt([update])
        self.assertIn(side, self.receipt["publication"]["commits"])
        self.receipt["publication"]["commits"].remove(side)
        self.assert_rejected("Outgoing history", [update])

    def test_empty_push_has_no_updates_to_verify(self):
        self.assertEqual(self.run_check([]).returncode, 0)

    def test_shallow_history_cannot_clear_publication(self):
        (self.root / ".git/shallow").write_text(self.base + "\n")
        self.assert_rejected("Shallow history")


    def test_hook_preserves_existing_rules_after_successful_match(self):
        self.write("ci_scripts/tasks/check_repository_rules.sh",
                   "#!/bin/bash\necho retained > .git/retained-rule-ran\n")
        destination = self.root / "ci_scripts/tasks/check_push_verification.py"
        destination.write_text(CHECKER.read_text())
        hook = self.root / ".git/hooks/pre-push"
        hook.write_text("#!/bin/bash\nset -euo pipefail\n"
                        "repository_root=$(git rev-parse --show-toplevel)\ncd \"$repository_root\"\n"
                        "python3 \"$repository_root/ci_scripts/tasks/check_push_verification.py\" \"$@\"\n"
                        "exec bash \"$repository_root/ci_scripts/tasks/check_repository_rules.sh\"\n")
        lines = " ".join(self.update[key] for key in ["local_ref", "local_oid", "remote_ref", "remote_oid"]) + "\n"
        q = subprocess.run(["bash", str(hook), "origin", "fixture://private"], cwd=self.root,
                           input=lines, capture_output=True, text=True)
        self.assertEqual(q.returncode, 0, q.stdout + q.stderr)
        self.assertEqual((self.root / ".git/retained-rule-ran").read_text(), "retained\n")
        (self.root / ".git/retained-rule-ran").unlink()
        (self.store / "receipt.json").unlink()
        q = subprocess.run(["bash", str(hook), "origin", "fixture://private"], cwd=self.root,
                           input=lines, capture_output=True, text=True)
        self.assertEqual(q.returncode, 1)
        self.assertFalse((self.root / ".git/retained-rule-ran").exists())

if __name__ == "__main__":
    unittest.main()
