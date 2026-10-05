"""Isolated tests for the Incomes pre-push scope/evidence pilot.

Fixtures are synthetic evidence, not successful Incomes builds or secret scans.
No Git push or network access is used.
"""
from __future__ import annotations

import copy
import hashlib
import json
import os
import shutil
import sys
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
        self.write(".swiftlint.yml", "strict: true\n")
        self.write("Incomes.xcodeproj/project.pbxproj", "Synthetic project fixture\n")
        self.write("Sources/value.swift", "let value = 1\n")
        self.commit("Initial")
        self.base = self.git("rev-parse", "HEAD")
        self.write("Sources/value.swift", "let value = 2\n")
        self.commit("Change value")
        self.tip = self.git("rev-parse", "HEAD")
        self.store = self.root / ".git/push-verification"
        self.store.mkdir()
        self.git("remote", "add", "origin", "fixture://private")
        self.environment = {"fixture": "isolated", "xcodebuild": "Synthetic Xcode", "swift": "Synthetic Swift"}
        self.binary_directory = self.root / ".git" / "fixture-tools"
        self.binary_directory.mkdir()
        self.original_path = os.environ["PATH"]
        self.make_binary("betterleaks", "import sys\nprint('1.9.0')\n")
        self.make_binary("xcrun", "import sys\nprint('Synthetic Xcode' if sys.argv[1] == 'xcodebuild' else 'Synthetic Swift')\n")
        os.environ["PATH"] = str(self.binary_directory) + os.pathsep + self.original_path
        self.receipt_path = self.store / "destinations" / hashlib.sha256(b"fixture://private").hexdigest() / "receipt.json"
        self.receipt_path.parent.mkdir(parents=True)
        self.update = self.tuple(self.tip, "refs/heads/main", self.base)
        self.receipt = self.make_receipt([self.update])
        self.save()

    def tearDown(self):
        os.environ["PATH"] = self.original_path
        self.temporary.cleanup()

    def make_binary(self, name, code):
        import sys
        binary = self.binary_directory / name
        binary.write_text(f"#!{sys.executable}\n" + code)
        binary.chmod(0o700)

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

    def record(self, name, oid=None, kind=None):
        oid = oid or self.tip
        directory = self.store / name
        directory.mkdir(exist_ok=True)
        log = directory / "output.log"
        log.write_text("Synthetic fixture output; not product verification.\n")
        source = {"head": oid, "tree": self.git("rev-parse", oid + "^{tree}"),
                  "clean": True, "status_sha256": hashlib.sha256(b"").hexdigest()}
        result = {"schema_version": 1,
                  "source": {"before": source, "after": source, "stable_clean_snapshot": True},
                  "environment": self.environment,
                  "verification": {"ran": True, "argv": ["fixture-only"], "exit_code": 0, "status": "passed"},
                  "diagnostics": {"complete_captured_output": True, "warning_count": 0,
                                  "error_count": 0, "warnings": [], "errors": []},
                  "tests": {"executed": 2, "failed": 0, "skipped": 0},
                  "artifacts": [{"path": "output.log", "sha256": hashlib.sha256(log.read_bytes()).hexdigest()}],
                  "evidence_errors": []}
        if kind == "lint":
            binary = "/fixture/artifacts/swiftlintplugins/SwiftLintBinary/SwiftLintBinary.artifactbundle/macos/swiftlint"
            files = [f for f in self.git("ls-tree", "-r", "--name-only", oid).splitlines() if f.endswith(".swift")]
            def source_hash(path):
                return hashlib.sha256(subprocess.check_output(["git", "show", oid + ":" + path], cwd=self.root)).hexdigest()
            proof = {"schema_version": 1, "mode": "lint", "exit_code": 0, "source_head": oid,
                     "binary": binary, "version": "0.65.1", "package_version": "0.65.1",
                     "package_remote": "https://github.com/SimplyDanny/SwiftLintPlugins",
                     "package_revision": "a" * 40, "project_sha256": source_hash("Incomes.xcodeproj/project.pbxproj"),
                     "config_sha256": source_hash(".swiftlint.yml"), "files": files,
                     "argv": [binary, "lint", "--quiet", "--no-cache", "--strict", *files]}
            proof.update({key: "a" * 64 for key in ("binary_sha256", "package_manifest_sha256",
                                                  "workspace_state_sha256", "artifact_checksum")})
            log.write_text("SwiftLint execution: " + json.dumps(proof) + "\nRepository rules check passed.\n")
            result["producer"] = "ci-verify-and-summarize"
            result["verification"]["argv"] = ["bash", "ci_scripts/tasks/check_repository_rules.sh"]
            result["artifacts"][0]["sha256"] = hashlib.sha256(log.read_bytes()).hexdigest()
        if kind in {"build", "tests"}:
            scheme = "Incomes" if kind == "build" else "IncomesLibrary"
            result["verification"]["argv"] = ["xcrun", "xcodebuild", "-scheme", scheme,
                "-resultBundlePath", "fixture-only.xcresult", "build" if kind == "build" else "test"]
            if kind == "tests":
                result["verification"]["argv"] += ["-testPlan", "IncomesLibrary"]
            build = {"status": "succeeded", "errorCount": 0, "warningCount": 0,
                     "analyzerWarningCount": 0, "errors": [], "warnings": [], "analyzerWarnings": []}
            result["native"] = {"complete_scope": True, "build": build}
            exports = {"native-build.json": build, "original-result.json": copy.deepcopy(result)}
            result["producer"] = "ci-verify-xcode-result-review"
            if kind == "tests":
                summary = {"result": "Passed", "passedTests": 2, "totalTestCount": 2, "failedTests": 0,
                           "skippedTests": 0, "expectedFailures": 0, "runtimeWarnings": [], "testFailures": []}
                bundles = {"IncomesLibraryTests": "Passed", "IncomesLibraryTimeZoneTests": "Passed"}
                result["native"].update(tests=summary, test_targets=bundles)
                exports.update({"native-tests.json": summary, "native-test-tree.json": {
                    "testNodes": [{"nodeType": "Unit test bundle", "name": name, "result": status}
                                  for name, status in bundles.items()]}})
            for filename, value in exports.items():
                path = directory / filename
                path.write_text(json.dumps(value))
                result["artifacts"].append({"path": filename, "sha256": hashlib.sha256(path.read_bytes()).hexdigest()})
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
            paths = {kind: self.record("quality-" + oid + "-" + kind, oid, kind)
                     for kind in ("build", "tests", "lint")}
            quality[oid] = {"tree": self.git("rev-parse", oid + "^{tree}"),
                            "environment": self.environment,
                            "checks": {kind: {"status": "passed", "evidence": path,
                                             "scope": "synthetic fixture", "skipped": 0}
                                       for kind, path in paths.items()}}
            quality[oid]["checks"]["diagnostics"] = {
                "status": "passed", "evidence": list(paths.values()), "scope": "all fixture records"}
        review = self.store / "contextual-review.txt"
        review.write_text("Synthetic review of all listed fixture commits.\n")
        scans = []
        for item in updates:
            name = "scan-" + hashlib.sha256(item["remote_ref"].encode()).hexdigest()
            base = None if item["remote_oid"] == ZERO else item["remote_oid"]
            report = self.store / (name + ".json")
            args = ["rev-list", item["local_oid"]] + (["--not", base] if base else [])
            report.write_text(json.dumps({"status": "clean", "scanner": "betterleaks",
                "scanner_version": "1.9.0", "head": item["local_oid"], "base": base,
                "new_ref": base is None, "validation": False, "commits": sorted(self.git(*args).splitlines()),
                "findings": []}))
            evidence = self.record(name)
            record_path = self.store / evidence
            record = json.loads(record_path.read_text())
            record["verification"]["argv"] = ["python3", "publication_tools.py", "scan", "--head", item["local_oid"], "--report", str(report)]
            record["verification"]["argv"] += ["--base", base] if base else ["--new-ref"]
            record_path.write_text(json.dumps(record))
            scans.append({"update": item, "evidence": evidence, "report": report.name,
                          "sha256": hashlib.sha256(report.read_bytes()).hexdigest()})
        return {"schema_version": 2, "common_git_dir": str(self.root / ".git"),
                "destination": {"remote_name": "origin", "location_sha256": hashlib.sha256(b"fixture://private").hexdigest()},
                "updates": sorted(updates, key=lambda item: item["remote_ref"]), "quality": quality,
                "publication": {"commits": sorted(commits), "uninspected": [],
                    "mechanical": {"status": "passed", "scanner": "betterleaks", "scanner_version": "1.9.0",
                                   "commits": sorted(commits), "scans": scans},
                    "contextual": {"status": "passed", "commits": sorted(commits),
                                   "report": "contextual-review.txt", "sha256": hashlib.sha256(review.read_bytes()).hexdigest()}}}

    def save(self):
        self.receipt_path.write_text(json.dumps(self.receipt))

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

    def test_scanner_success_cannot_replace_lint_execution(self):
        checks = self.receipt["quality"][self.tip]["checks"]
        old = checks["lint"]["evidence"]
        checks["lint"]["evidence"] = self.receipt["publication"]["mechanical"]["scans"][0]["evidence"]
        checks["diagnostics"]["evidence"].remove(old)
        checks["diagnostics"]["evidence"].append(checks["lint"]["evidence"])
        self.assert_rejected("repository rules execution")

    def test_lint_source_tool_scope_and_execution_mismatch_reject(self):
        path = self.store / self.receipt["quality"][self.tip]["checks"]["lint"]["evidence"]
        original = json.loads(path.read_text())
        output = path.parent / "output.log"
        original_output = output.read_text()
        proof = json.loads(original_output.splitlines()[0].removeprefix("SwiftLint execution: "))
        for key, value in (("source_head", self.base), ("binary_sha256", "missing"),
                           ("version", "0.65.2"), ("project_sha256", "a" * 64),
                           ("config_sha256", "a" * 64), ("files", []), ("mode", "format"),
                           ("argv", [proof["binary"], "version"]), ("exit_code", 2)):
            with self.subTest(key=key):
                changed = dict(proof); changed[key] = value
                output.write_text("SwiftLint execution: " + json.dumps(changed) + "\nRepository rules check passed.\n")
                record = copy.deepcopy(original)
                record["artifacts"][0]["sha256"] = hashlib.sha256(output.read_bytes()).hexdigest()
                path.write_text(json.dumps(record))
                self.assert_rejected("SwiftLint execution")
        output.write_text("Repository rules check passed.\n")
        original["artifacts"][0]["sha256"] = hashlib.sha256(output.read_bytes()).hexdigest()
        path.write_text(json.dumps(original))
        self.assert_rejected("completed SwiftLint execution")

    def test_missing_receipt_rejects(self):
        self.receipt_path.unlink()
        self.assertEqual(self.run_check().returncode, 1)

    def test_destination_mismatch_rejects(self):
        self.assert_rejected("destination", remote="fixture://different")

    def test_sha_ref_and_base_mismatch_reject(self):
        for key, value in [("local_oid", self.base), ("remote_ref", "refs/heads/other"), ("remote_oid", ZERO)]:
            with self.subTest(key=key):
                update = dict(self.update)
                update[key] = value
                self.assert_rejected("source ref" if key == "local_oid" else "source SHA, refs", [update])

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
        original_records = {kind: self.receipt["quality"][self.tip]["checks"][kind]["evidence"] for kind in ("build", "tests", "lint")}
        old = self.tip
        self.write("README.md", "Only prose changed\n")
        self.commit("Explain usage")
        doc_tip = self.git("rev-parse", "HEAD")
        update = self.tuple(doc_tip, "refs/heads/main", self.base)
        self.receipt = self.make_receipt([update])
        checks = self.receipt["quality"][doc_tip]["checks"]
        for kind in ["build", "tests", "lint"]:
            checks[kind].update(status="reused", evidence=original_records[kind])
        checks["diagnostics"]["evidence"] = list(original_records.values())
        self.save()
        self.assertEqual(self.run_check([update]).returncode, 0)
        self.write("Sources/value.swift", "let value = 4\n")
        self.commit("Change code")
        code_tip = self.git("rev-parse", "HEAD")
        update = self.tuple(code_tip, "refs/heads/main", self.base)
        self.receipt = self.make_receipt([update])
        checks = self.receipt["quality"][code_tip]["checks"]
        for kind in ["build", "tests", "lint"]:
            checks[kind].update(status="reused", evidence=original_records[kind])
        checks["diagnostics"]["evidence"] = list(original_records.values())
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
                        {"diagnostics": {"warning_count": 1}}]:
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
        self.assert_rejected("toolchain changed")
        self.receipt["quality"][self.tip]["environment"] = self.environment
        self.receipt["publication"]["uninspected"] = ["binary fixture"]
        self.assert_rejected("remain uninspected")

    def test_scanner_report_findings_and_tamper_are_not_ai_clean_claims(self):
        scan = self.receipt["publication"]["mechanical"]["scans"][0]
        path = self.store / scan["report"]
        data = json.loads(path.read_text())
        data["findings"] = [{"RuleID": "synthetic-fixture"}]
        path.write_text(json.dumps(data))
        scan["sha256"] = hashlib.sha256(path.read_bytes()).hexdigest()
        self.assert_rejected("scanner report has findings")
        path.write_text("{}")
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


    def test_scanner_missing_or_unsupported_version_rejects(self):
        binary = self.binary_directory / "betterleaks"
        for version in ("2.0.0-rc.1", "1.9.1"):
            self.make_binary("betterleaks", f"print({version!r})\n")
            self.assert_rejected("Unsupported Betterleaks")
        binary.unlink()
        (self.binary_directory / "python3").symlink_to(sys.executable)
        (self.binary_directory / "git").symlink_to(shutil.which("git"))
        os.environ["PATH"] = str(self.binary_directory)
        self.assert_rejected("Betterleaks is missing")

    def test_incomplete_native_tests_or_subset_cannot_clear_quality(self):
        path = self.store / self.receipt["quality"][self.tip]["checks"]["tests"]["evidence"]
        original = json.loads(path.read_text())
        for mutation in (lambda r: r["tests"].update(executed=0),
                         lambda r: r["tests"].update(skipped=1),
                         lambda r: r["native"].update(complete_scope=False),
                         lambda r: r["verification"]["argv"].append("-only-testing:IncomesLibraryTests/OneTest")):
            record = copy.deepcopy(original)
            mutation(record)
            path.write_text(json.dumps(record))
            self.assertEqual(self.run_check().returncode, 1)

    def test_scanner_command_must_bind_engine_report_and_range(self):
        scan = self.receipt["publication"]["mechanical"]["scans"][0]
        path = self.store / scan["evidence"]
        original = json.loads(path.read_text())
        for mutation in (lambda a: a.__setitem__(1, "unrelated.py"),
                         lambda a: a.__setitem__(a.index("--report") + 1, "other.json"),
                         lambda a: a.extend(["--head", self.tip])):
            record = copy.deepcopy(original)
            mutation(record["verification"]["argv"])
            path.write_text(json.dumps(record))
            self.assertEqual(self.run_check().returncode, 1)

    def test_stale_toolchain_requires_new_quality_evidence(self):
        self.make_binary("xcrun", "print('Different Xcode or Swift')\n")
        self.assert_rejected("toolchain changed")

    def test_invalid_source_or_destination_ref_rejects(self):
        for field, value in (("remote_ref", "refs/heads/bad..name"),
                             ("remote_ref", "refs/tags/release"),
                             ("local_ref", "refs/heads/absent")):
            update = dict(self.update)
            update[field] = value
            self.save()
            self.assertEqual(self.run_check([update]).returncode, 1)

    def test_missing_duplicate_or_wrong_range_scans_reject(self):
        mechanical = self.receipt["publication"]["mechanical"]
        original = copy.deepcopy(mechanical)
        mechanical["scans"] = []
        self.assert_rejected("Every proposed ref")
        self.receipt["publication"]["mechanical"] = copy.deepcopy(original)
        scan = self.receipt["publication"]["mechanical"]["scans"][0]
        path = self.store / scan["report"]
        data = json.loads(path.read_text())
        for field, value in (("validation", True), ("scanner_version", "2.0.0-rc.1"),
                             ("head", self.base), ("commits", [])):
            changed = dict(data)
            changed[field] = value
            path.write_text(json.dumps(changed))
            scan["sha256"] = hashlib.sha256(path.read_bytes()).hexdigest()
            self.assert_rejected("unsupported coverage")
        path.write_text(json.dumps(data))
        scan["sha256"] = hashlib.sha256(path.read_bytes()).hexdigest()

    def test_independent_destination_receipts_do_not_overwrite(self):
        second = "fixture://secondary"
        self.git("remote", "add", "secondary", second)
        path = self.store / "destinations" / hashlib.sha256(second.encode()).hexdigest() / "receipt.json"
        path.parent.mkdir()
        receipt = copy.deepcopy(self.receipt)
        receipt["destination"] = {"remote_name": "secondary", "location_sha256": hashlib.sha256(second.encode()).hexdigest()}
        path.write_text(json.dumps(receipt))
        lines = " ".join(self.update[key] for key in ("local_ref", "local_oid", "remote_ref", "remote_oid")) + "\n"
        result = subprocess.run(["python3", str(CHECKER), "secondary", second], cwd=self.root,
                                input=lines, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.run_check().returncode, 0)
        path.unlink()
        result = subprocess.run(["python3", str(CHECKER), "secondary", second], cwd=self.root,
                                input=lines, capture_output=True, text=True)
        self.assertEqual(result.returncode, 1)

    def test_explicit_reviewed_git_url_is_supported(self):
        url = "https://example.invalid/reviewed-repository.git"
        receipt = copy.deepcopy(self.receipt)
        receipt["destination"] = {"remote_name": url, "location_sha256": hashlib.sha256(url.encode()).hexdigest()}
        path = self.store / "destinations" / hashlib.sha256(url.encode()).hexdigest() / "receipt.json"
        path.parent.mkdir()
        path.write_text(json.dumps(receipt))
        lines = " ".join(self.update[key] for key in ("local_ref", "local_oid", "remote_ref", "remote_oid")) + "\n"
        result = subprocess.run(["python3", str(CHECKER), url, url], cwd=self.root,
                                input=lines, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_thin_hook_matches_evidence_without_repeating_rules(self):
        self.write("ci_scripts/tasks/check_repository_rules.sh",
                   "#!/bin/bash\necho retained > .git/retained-rule-ran\n")
        destination = self.root / "ci_scripts/tasks/check_push_verification.py"
        destination.write_text(CHECKER.read_text())
        hook = self.root / ".git/hooks/pre-push"
        hook.write_text("#!/bin/bash\nset -euo pipefail\n"
                        "repository_root=$(git rev-parse --show-toplevel)\ncd \"$repository_root\"\n"
                        "exec python3 \"$repository_root/ci_scripts/tasks/check_push_verification.py\" \"$@\"\n")
        lines = " ".join(self.update[key] for key in ["local_ref", "local_oid", "remote_ref", "remote_oid"]) + "\n"
        q = subprocess.run(["bash", str(hook), "origin", "fixture://private"], cwd=self.root,
                           input=lines, capture_output=True, text=True)
        self.assertEqual(q.returncode, 0, q.stdout + q.stderr)
        self.assertFalse((self.root / ".git/retained-rule-ran").exists())
        self.receipt_path.unlink()
        q = subprocess.run(["bash", str(hook), "origin", "fixture://private"], cwd=self.root,
                           input=lines, capture_output=True, text=True)
        self.assertEqual(q.returncode, 1)
        self.assertFalse((self.root / ".git/retained-rule-ran").exists())

if __name__ == "__main__":
    unittest.main()
