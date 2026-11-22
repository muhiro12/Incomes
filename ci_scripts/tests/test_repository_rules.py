"""Exercise project-managed SwiftLint and repository boundary checks."""
from __future__ import annotations

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
sys.path.insert(0, str(REPOSITORY / "ci_scripts/lib"))
import swiftlint_binary


class SwiftLintTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name).resolve()
        (self.root / "Incomes.xcodeproj").mkdir()
        project = {"rootObject": "root", "objects": {
            "root": {"isa": "PBXProject", "packageReferences": ["fixture"], "targets": []},
            "fixture": {"isa": "XCRemoteSwiftPackageReference", "repositoryURL": swiftlint_binary.SWIFTLINT_REMOTE,
                        "requirement": {"kind": "upToNextMajorVersion", "minimumVersion": "0.0.0"}}}}
        (self.root / "Incomes.xcodeproj/project.pbxproj").write_bytes(plistlib.dumps(project))
        self.git(self.root, "init", "-q")
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
        reference = {"identity": "swiftlintplugins", "location": swiftlint_binary.SWIFTLINT_REMOTE}
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

    def test_lint_and_format_run_the_selected_binary_and_propagate_failures(self):
        shutil.copytree(REPOSITORY / "ci_scripts", self.root / "ci_scripts")
        (self.root / ".gitignore").write_text("cache/\nIgnored.swift\n")
        for name in ("Tracked.swift", "New File.swift", "Ignored.swift"):
            (self.root / name).touch()
        self.git(self.root, "add", "Tracked.swift")
        self.binary.write_text(
            f"#!{sys.executable}\n"
            "import json, os, sys\n"
            "if sys.argv[1] == 'version':\n"
            "    print('0.65.1')\n"
            "else:\n"
            "    print(json.dumps(sys.argv[1:]))\n"
            "    sys.exit(int(os.environ['FIXTURE_LINT_EXIT']))\n"
        )
        for mode, flags in (("lint", ["--strict"]), ("format", ["--fix", "--format"])):
            for status in (0, 7):
                with self.subTest(mode=mode, status=status):
                    result = subprocess.run(
                        ["bash", f"ci_scripts/tasks/{mode}_swift.sh"], cwd=self.root,
                        env={**os.environ, "CI_SWIFT_PACKAGE_DIR": str(self.cache), "FIXTURE_LINT_EXIT": str(status)},
                        capture_output=True, text=True,
                    )
                    self.assertEqual(result.returncode, status, result.stderr)
                    args = [json.loads(line) for line in result.stdout.splitlines() if line.startswith("[")]
                    self.assertEqual(args, [["lint", "--quiet", "--no-cache", *flags, "Tracked.swift", "New File.swift"]])

    def test_actual_version_mismatch_is_incomplete(self):
        self.binary.write_text(f"#!{sys.executable}\nprint('0.65.2')\n")
        with self.assertRaisesRegex(ValueError, "actual SwiftLint binary version"):
            swiftlint_binary.select(self.root, [self.cache])

    def test_json_project_selects_the_registered_binary(self):
        legacy = self.root / "Incomes.xcodeproj/project.pbxproj"
        legacy.unlink()
        project = self.root / "Incomes.xcodeproj/project.xcproj"
        project.write_text(json.dumps({"packages": [{"kind": "remote", "repository": swiftlint_binary.SWIFTLINT_REMOTE,
            "version": {"up-to-next-major-version": "0.0.0"}}], "targets": []}))
        self.assertEqual(swiftlint_binary.select(self.root, [self.cache]), self.binary)

    def test_wrong_package_or_project_requirement_is_incomplete(self):
        self.state["object"]["dependencies"][0]["packageRef"]["location"] = "https://example.invalid/Other"
        self.save()
        with self.assertRaisesRegex(ValueError, "different source"):
            swiftlint_binary.select(self.root, [self.cache])

    def test_unregistered_override_and_other_repo_cache_are_not_selected(self):
        os.environ["CI_XCODE_GLOBAL_DERIVED_DATA_DIR"] = str(self.cache)
        self.assertIsNone(swiftlint_binary.select(self.root, [self.root / "missing"]))
        os.environ["CI_SWIFTLINT_BIN"] = str(self.binary)
        with self.assertRaisesRegex(ValueError, "registered artifact"):
            swiftlint_binary.select(self.root, [self.root / "missing"])
        self.assertEqual(swiftlint_binary.select(self.root, [self.cache]), self.binary)

    def test_missing_or_changed_package_resolution_is_incomplete(self):
        self.state["object"]["dependencies"][0]["state"]["checkoutState"]["revision"] = "b" * 40
        self.save()
        with self.assertRaisesRegex(ValueError, "checkout changed"):
            swiftlint_binary.select(self.root, [self.cache])
        (self.cache / "workspace-state.json").unlink()
        with self.assertRaises(OSError):
            swiftlint_binary.select(self.root, [self.cache])


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
