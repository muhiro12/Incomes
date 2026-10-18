"""Project format compatibility and package-boundary regression coverage."""
from __future__ import annotations

import copy
import json
from pathlib import Path
import plistlib
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
            "targets": [{"name": "Incomes", "build-phases": ["frameworks"],
                         "package-product-members": [{"product-name": "MHPlatform", "package": "MHPlatform",
                                                      "build-phase": {"build-phase": "frameworks"}}]},
                        {"name": "Watch"}, {"name": "Widgets"}],
        }

    def tearDown(self):
        self.temporary.cleanup()

    def check(self, configuration):
        project.check_mhplatform(project.summarize_project(configuration), "1.14.0")

    def legacy_configuration(self):
        return {"rootObject": "root", "objects": {
            "root": {"isa": "PBXProject", "packageReferences": ["package"],
                     "targets": ["app", "watch", "widgets"]},
            "package": {"isa": "XCRemoteSwiftPackageReference", "repositoryURL": project.MHPLATFORM_REMOTE,
                        "requirement": {"kind": "upToNextMajorVersion", "minimumVersion": "1.14.0"}},
            "product": {"isa": "XCSwiftPackageProductDependency", "productName": "MHPlatform", "package": "package"},
            "app": {"isa": "PBXNativeTarget", "name": "Incomes", "packageProductDependencies": ["product"],
                    "buildPhases": ["frameworks"]},
            "watch": {"isa": "PBXNativeTarget", "name": "Watch", "buildPhases": ["watch-frameworks"]},
            "widgets": {"isa": "PBXNativeTarget", "name": "Widgets"},
            "frameworks": {"isa": "PBXFrameworksBuildPhase", "files": ["build-file"]},
            "watch-frameworks": {"isa": "PBXFrameworksBuildPhase", "files": []},
            "build-file": {"isa": "PBXBuildFile", "productRef": "product"},
        }}

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

    def test_json_filename_cannot_disguise_a_legacy_object_model(self):
        (self.bundle / "project.xcproj").write_text(json.dumps(self.legacy_configuration()))
        with self.assertRaisesRegex(ValueError, "legacy object model"):
            project.load_project(self.root)

    def test_expected_umbrella_adoption_is_valid(self):
        self.check(self.configuration)

    def test_branch_revision_and_different_version_are_rejected(self):
        for version in ({"branch": "main"}, {"revision": "a" * 40}, {"exact-version": "1.14.0"},
                        {"up-to-next-major-version": "1.15.0"}):
            with self.subTest(version=version):
                configuration = copy.deepcopy(self.configuration)
                configuration["packages"][0]["version"] = version
                with self.assertRaisesRegex(ValueError, "semver requirement"):
                    self.check(configuration)

    def test_missing_duplicate_and_noncanonical_package_are_rejected(self):
        for packages in ([], self.configuration["packages"] * 2,
                         [{"kind": "remote", "repository": "https://example.invalid/MHPlatform"}]):
            with self.subTest(packages=packages):
                configuration = dict(self.configuration, packages=packages)
                with self.assertRaises(ValueError):
                    self.check(configuration)

    def test_local_package_and_adapter_umbrella_adoption_are_rejected(self):
        local = copy.deepcopy(self.configuration)
        local["packages"].append({"kind": "local", "path": "../MHPlatform"})
        with self.assertRaises(ValueError):
            self.check(local)
        for index in range(3):
            with self.subTest(target=index):
                configuration = copy.deepcopy(self.configuration)
                configuration["targets"][index]["package-product-members"] = (
                    [] if index == 0 else [{"product-name": "MHPlatform"}])
                with self.assertRaises(ValueError):
                    self.check(configuration)

    def test_json_requires_framework_link_and_correct_product_owner(self):
        for case in ("no link", "wrong phase", "no Frameworks phase", "missing owner", "foreign owner", "duplicate"):
            with self.subTest(case=case):
                configuration = copy.deepcopy(self.configuration)
                target = configuration["targets"][0]
                member = target["package-product-members"][0]
                if case == "no link":
                    member.pop("build-phase")
                elif case == "wrong phase":
                    member["build-phase"] = {"build-phase": "resources"}
                elif case == "no Frameworks phase":
                    target["build-phases"] = []
                elif case == "missing owner":
                    member.pop("package")
                elif case == "foreign owner":
                    configuration["packages"].append({"kind": "remote", "repository": "https://example.invalid/Other"})
                    member["package"] = "Other"
                else:
                    target["package-product-members"].append(copy.deepcopy(member))
                with self.assertRaisesRegex(ValueError, "declare and link"):
                    self.check(configuration)

    def test_json_adapter_framework_file_cannot_bypass_product_boundary(self):
        for membership in ("Watch/frameworks", "Watch", {"build-phase": "Watch/frameworks"}):
            with self.subTest(membership=membership):
                configuration = copy.deepcopy(self.configuration)
                configuration["files"] = [{"kind": "group", "children": [
                    {"path": "MHPlatform.framework", "target-membership": [membership]}]}]
                with self.assertRaisesRegex(ValueError, "only target"):
                    self.check(configuration)

    def test_legacy_project_preserves_valid_package_and_framework_edges(self):
        path = self.bundle / "project.pbxproj"
        path.write_bytes(plistlib.dumps(self.legacy_configuration()))
        _, configuration = project.load_project(self.root)
        project.check_mhplatform(configuration, "1.14.0")

    def test_legacy_rejects_missing_links_foreign_owners_and_orphan_packages(self):
        for case in ("no link", "foreign owner", "orphan package", "adapter link"):
            with self.subTest(case=case):
                document = self.legacy_configuration()
                objects = document["objects"]
                if case == "no link":
                    objects["frameworks"]["files"] = []
                elif case == "foreign owner":
                    objects["other"] = {"isa": "XCRemoteSwiftPackageReference", "repositoryURL": "https://example.invalid/Other",
                                        "requirement": {"kind": "upToNextMajorVersion", "minimumVersion": "1.14.0"}}
                    objects["root"]["packageReferences"].append("other")
                    objects["product"]["package"] = "other"
                elif case == "orphan package":
                    objects["root"]["packageReferences"] = []
                else:
                    objects["watch-frameworks"]["files"] = ["build-file"]
                path = self.bundle / "project.pbxproj"
                path.write_bytes(plistlib.dumps(document))
                with self.assertRaises(ValueError):
                    _, configuration = project.load_project(self.root)
                    project.check_mhplatform(configuration, "1.14.0")

    def test_orphan_legacy_swiftlint_object_is_not_a_declared_dependency(self):
        document = self.legacy_configuration()
        document["objects"]["orphan"] = {"isa": "XCRemoteSwiftPackageReference", "repositoryURL": project.SWIFTLINT_REMOTE,
                                         "requirement": {"kind": "upToNextMajorVersion", "minimumVersion": "0.0.0"}}
        path = self.bundle / "project.pbxproj"
        path.write_bytes(plistlib.dumps(document))
        _, configuration = project.load_project(self.root)
        with self.assertRaisesRegex(ValueError, "canonical SwiftLintPlugins"):
            project.remote_package(configuration, project.SWIFTLINT_REMOTE)


if __name__ == "__main__":
    unittest.main()
