"""Negative fixtures for retained boundary searches and SwiftLint provenance."""
from __future__ import annotations

import importlib.util
import json
import os
from pathlib import Path
import plistlib
import shutil
import subprocess
import sys
import tempfile
import unittest

REPOSITORY = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location("swiftlint_evidence", REPOSITORY / "ci_scripts/lib/swiftlint_evidence.py")
adapter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(adapter)


class SwiftLintEvidenceTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name).resolve()
        (self.root / "Incomes.xcodeproj").mkdir()
        project = {"objects": {"fixture": {"isa": "XCRemoteSwiftPackageReference", "repositoryURL": adapter.REMOTE,
                   "requirement": {"kind": "upToNextMajorVersion", "minimumVersion": "0.0.0"}}}}
        (self.root / "Incomes.xcodeproj/project.pbxproj").write_bytes(plistlib.dumps(project))
        (self.root / ".swiftlint.yml").write_text("strict: true\n")
        (self.root / "Value.swift").write_text("let value = 1\n")
        self.git(self.root, "init", "-q")
        self.git(self.root, "add", ".")
        self.git(self.root, "-c", "user.name=Fixture", "-c", "user.email=fixture@example.invalid", "commit", "-qm", "Fixture")
        self.cache = self.root / "cache"
        self.package = self.cache / "checkouts/SwiftLintPlugins"
        self.package.mkdir(parents=True)
        self.url = "https://github.com/realm/SwiftLint/releases/download/0.65.1/SwiftLintBinary.artifactbundle.zip"
        (self.package / "Package.swift").write_text(self.url + '\n"' + "a" * 64 + '"\n')
        self.git(self.package, "init", "-q")
        self.git(self.package, "add", ".")
        self.git(self.package, "-c", "user.name=Fixture", "-c", "user.email=fixture@example.invalid", "commit", "-qm", "Package fixture")
        bundle = self.cache / "artifacts/swiftlintplugins/SwiftLintBinary/SwiftLintBinary.artifactbundle"
        self.binary = bundle / "macos/swiftlint"
        self.binary.parent.mkdir(parents=True)
        self.binary.write_text(f"#!{sys.executable}\nimport sys\nif sys.argv[1]=='version': print('0.65.1')\n")
        self.binary.chmod(0o700)
        (bundle / "info.json").write_text(json.dumps({"artifacts": {"swiftlint": {"type": "executable",
            "version": "0.65.1", "variants": [{"path": "macos/swiftlint"}]}}}))
        reference = {"identity": "swiftlintplugins", "location": adapter.REMOTE}
        self.state = {"object": {"dependencies": [{"packageRef": reference, "subpath": "SwiftLintPlugins",
            "state": {"checkoutState": {"version": "0.65.1", "revision": self.git(self.package, "rev-parse", "HEAD")}}}],
            "artifacts": [{"packageRef": reference, "targetName": "SwiftLintBinary",
                           "source": {"type": "remote", "url": self.url, "checksum": "a" * 64}}]}}
        self.save()
        self.environment = dict(os.environ)
        os.environ.pop("CI_SWIFTLINT_BIN", None)

    def tearDown(self):
        os.environ.clear(); os.environ.update(self.environment)
        self.temporary.cleanup()

    def git(self, root, *args):
        return subprocess.check_output(["git", "-C", str(root), *args], text=True).strip()

    def save(self):
        (self.cache / "workspace-state.json").write_text(json.dumps(self.state))

    def test_registered_binary_and_actual_execution_are_recorded(self):
        selected = adapter.select(self.root, [self.cache])
        self.assertEqual(selected["version"], "0.65.1")
        self.assertEqual(selected["binary_sha256"], adapter.sha256(self.binary))
        q = subprocess.run([sys.executable, str(REPOSITORY / "ci_scripts/lib/swiftlint_evidence.py"), "run",
                            str(self.root), str(self.cache), str(self.root / "unused"), "lint", "Value.swift"],
                           capture_output=True, text=True)
        self.assertEqual(q.returncode, 0, q.stderr)
        proof = json.loads(q.stdout.removeprefix(adapter.MARKER))
        self.assertEqual(proof["files"], ["Value.swift"])
        self.assertEqual(proof["mode"], "lint")
        self.assertEqual(proof["argv"][-2:], ["--strict", "Value.swift"])

    def test_actual_version_mismatch_is_incomplete(self):
        self.binary.write_text(f"#!{sys.executable}\nprint('0.65.2')\n")
        with self.assertRaisesRegex(ValueError, "actual SwiftLint binary version"):
            adapter.select(self.root, [self.cache])

    def test_wrong_package_or_project_requirement_is_incomplete(self):
        self.state["object"]["dependencies"][0]["packageRef"]["location"] = "https://example.invalid/Other"
        self.save()
        with self.assertRaisesRegex(ValueError, "different source"):
            adapter.select(self.root, [self.cache])

    def test_unregistered_override_and_other_repo_cache_are_not_selected(self):
        os.environ["CI_XCODE_GLOBAL_DERIVED_DATA_DIR"] = str(self.cache)
        self.assertIsNone(adapter.select(self.root, [self.root / "missing"]))
        os.environ["CI_SWIFTLINT_BIN"] = str(self.binary)
        with self.assertRaisesRegex(ValueError, "registered artifact"):
            adapter.select(self.root, [self.root / "missing"])
        self.assertEqual(adapter.select(self.root, [self.cache])["binary"], str(self.binary))

    def test_missing_or_changed_package_resolution_is_incomplete(self):
        self.state["object"]["dependencies"][0]["state"]["checkoutState"]["revision"] = "b" * 40
        self.save()
        with self.assertRaisesRegex(ValueError, "checkout changed"):
            adapter.select(self.root, [self.cache])
        (self.cache / "workspace-state.json").unlink()
        with self.assertRaises(OSError):
            adapter.select(self.root, [self.cache])


class BoundarySearchTests(unittest.TestCase):
    def test_search_match_absence_and_failure_have_distinct_results(self):
        # Run the complete actual scripts. A shell rg function injects failure
        # after the normal metadata inputs, without changing repository files.
        native = shutil.which("rg")
        self.assertIsNotNone(native)
        for name in ("check_incomes_architecture_boundaries.sh", "check_mhplatform_boundaries.sh"):
            script = REPOSITORY / "ci_scripts/tasks" / name
            for mode in ("normal", "scan_failure", "predicate_failure"):
                with self.subTest(script=name, mode=mode):
                    code = 'rg() { if [[ "$RULE_TEST_MODE" == "normal" || ( "$RULE_TEST_MODE" == "scan_failure" && "$1" != "--line-number" ) ]]; then "$RULE_TEST_RG" "$@"; else return 2; fi; }; export -f rg; bash "$RULE_TEST_SCRIPT"'
                    q = subprocess.run(["bash", "-c", code], cwd=REPOSITORY, capture_output=True, text=True,
                        env={**os.environ, "RULE_TEST_MODE": mode, "RULE_TEST_RG": native, "RULE_TEST_SCRIPT": str(script)})
                    self.assertEqual(q.returncode, 0 if mode == "normal" else 2, q.stdout + q.stderr)
                    if mode != "normal":
                        self.assertIn("search incomplete", q.stderr)


if __name__ == "__main__":
    unittest.main()
