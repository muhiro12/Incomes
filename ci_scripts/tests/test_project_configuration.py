"""Project format compatibility and package-boundary regression coverage."""
from __future__ import annotations

import copy
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "lib"))
import project_configuration as project


class ProjectConfigurationTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        self.bundle = self.root / "Incomes.xcodeproj"
        self.bundle.mkdir()
        self.configuration = {
            "packages": [{"kind": "remote", "repository": project.MHPLATFORM_REMOTE,
                          "version": {"up-to-next-major-version": "1.14.0"}}],
            "targets": [{"name": "Incomes", "package-product-members": [{"product-name": "MHPlatform"}]},
                        {"name": "Watch"}, {"name": "Widgets"}],
        }

    def tearDown(self):
        self.temporary.cleanup()

    def test_native_json5_reader_preserves_strings_and_trailing_commas(self):
        path = self.bundle / "project.xcproj"
        path.write_text('''{
            // Xcode's project syntax permits trailing commas.
            "packages": [{"kind": "remote", "repository": "https://example.invalid/a,]//b",},],
            "targets": [],
        }''')
        actual, configuration = project.load_project(self.root)
        self.assertEqual(actual, path)
        self.assertEqual(configuration["packages"][0]["repository"], "https://example.invalid/a,]//b")

    def test_missing_and_ambiguous_formats_are_incomplete(self):
        for names in ([], ["project.pbxproj", "project.xcproj"]):
            with self.subTest(names=names):
                for name in names:
                    (self.bundle / name).write_text("{}")
                with self.assertRaisesRegex(ValueError, "exactly one"):
                    project.load_project(self.root)

    def test_malformed_json_is_incomplete(self):
        (self.bundle / "project.xcproj").write_text('{"packages": [')
        with self.assertRaises(subprocess.CalledProcessError):
            project.load_project(self.root)

    def test_expected_umbrella_adoption_is_valid(self):
        project.check_mhplatform(self.configuration, "1.14.0")

    def test_branch_revision_and_different_version_are_rejected(self):
        for version in ({"branch": "main"}, {"revision": "a" * 40}, {"exact-version": "1.14.0"},
                        {"up-to-next-major-version": "1.15.0"}):
            with self.subTest(version=version):
                configuration = copy.deepcopy(self.configuration)
                configuration["packages"][0]["version"] = version
                with self.assertRaisesRegex(ValueError, "semver requirement"):
                    project.check_mhplatform(configuration, "1.14.0")

    def test_missing_duplicate_and_noncanonical_package_are_rejected(self):
        for packages in ([], self.configuration["packages"] * 2,
                         [{"kind": "remote", "repository": "https://example.invalid/MHPlatform"}]):
            with self.subTest(packages=packages):
                configuration = dict(self.configuration, packages=packages)
                with self.assertRaisesRegex(ValueError, "canonical MHPlatform"):
                    project.check_mhplatform(configuration, "1.14.0")

    def test_local_package_and_adapter_umbrella_adoption_are_rejected(self):
        local = copy.deepcopy(self.configuration)
        local["packages"].append({"kind": "local", "path": "../MHPlatform"})
        with self.assertRaisesRegex(ValueError, "local MHPlatform"):
            project.check_mhplatform(local, "1.14.0")
        for index in range(3):
            with self.subTest(target=index):
                configuration = copy.deepcopy(self.configuration)
                configuration["targets"][index]["package-product-members"] = (
                    [] if index == 0 else [{"product-name": "MHPlatform"}])
                with self.assertRaisesRegex(ValueError, "only target"):
                    project.check_mhplatform(configuration, "1.14.0")


if __name__ == "__main__":
    unittest.main()
