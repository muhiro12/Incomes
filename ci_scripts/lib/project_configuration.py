#!/usr/bin/env python3
"""Read either supported Xcode project format for retained repository checks."""
from __future__ import annotations

import json
from pathlib import Path
import subprocess
import sys

PROJECT_FILES = ("project.pbxproj", "project.xcproj")
SWIFTLINT_REMOTE = "https://github.com/SimplyDanny/SwiftLintPlugins"
MHPLATFORM_REMOTE = "https://github.com/muhiro12/MHPlatform"

# Xcode writes trailing commas. Foundation accepts its JSON5 syntax without
# introducing a Python dependency or changing strings with a text substitution.
JSON5_READER = """
import Foundation
do {
    let data = FileHandle.standardInput.readDataToEndOfFile()
    let object = try JSONSerialization.jsonObject(with: data, options: [.json5Allowed])
    FileHandle.standardOutput.write(try JSONSerialization.data(withJSONObject: object))
} catch {
    FileHandle.standardError.write(Data("Invalid JSON project configuration.\\n".utf8))
    exit(2)
}
"""


def load_project(repository: Path) -> tuple[Path, dict]:
    candidates = [repository / "Incomes.xcodeproj" / name for name in PROJECT_FILES]
    candidates = [path for path in candidates if path.is_file()]
    if len(candidates) != 1:
        raise ValueError("Incomes.xcodeproj must contain exactly one supported project configuration.")
    project = candidates[0]
    if project.suffix == ".xcproj":
        parsed = subprocess.run(["xcrun", "swift", "-e", JSON5_READER], input=project.read_bytes(),
                                check=True, capture_output=True)
        configuration = json.loads(parsed.stdout)
        if not isinstance(configuration.get("packages"), list) or not isinstance(configuration.get("targets"), list):
            raise ValueError("The JSON project must declare packages and targets.")
        return project, configuration

    parsed = subprocess.run(["plutil", "-convert", "json", "-o", "-", str(project)],
                            check=True, capture_output=True)
    objects = json.loads(parsed.stdout)["objects"]
    packages = []
    targets = []
    for value in objects.values():
        if value.get("isa") == "XCRemoteSwiftPackageReference":
            requirement = value["requirement"]
            version = ({"up-to-next-major-version": requirement["minimumVersion"]}
                       if requirement.get("kind") == "upToNextMajorVersion" else {"unsupported": requirement})
            packages.append({"kind": "remote", "repository": value["repositoryURL"], "version": version})
        elif value.get("isa") == "XCLocalSwiftPackageReference":
            packages.append({"kind": "local", "path": value["relativePath"]})
        elif value.get("isa") == "PBXNativeTarget":
            products = [{"product-name": objects[identifier]["productName"]}
                        for identifier in value.get("packageProductDependencies", [])]
            targets.append({"name": value["name"], "package-product-members": products})
    return project, {"packages": packages, "targets": targets}


def remote_package(configuration: dict, remote: str) -> dict:
    references = [value for value in configuration["packages"] if value.get("kind") == "remote"
                  and value.get("repository", "").removesuffix(".git") == remote]
    if len(references) != 1:
        raise ValueError(f"The project must declare one canonical {remote.rsplit('/', 1)[-1]} dependency.")
    return references[0]


def check_mhplatform(configuration: dict, minimum: str) -> None:
    if any(value.get("kind") == "local" and Path(value["path"]).name == "MHPlatform"
           for value in configuration["packages"]):
        raise ValueError("Incomes.xcodeproj must not use a local MHPlatform package reference.")
    reference = remote_package(configuration, MHPLATFORM_REMOTE)
    if reference.get("version") != {"up-to-next-major-version": minimum}:
        raise ValueError(f"Incomes.xcodeproj must use the MHPlatform 1.x semver requirement from {minimum}.")
    for name in ("Incomes", "Watch", "Widgets"):
        targets = [value for value in configuration["targets"] if value.get("name") == name]
        if len(targets) != 1:
            raise ValueError(f"Incomes.xcodeproj must declare one {name} target.")
        products = [value["product-name"] for value in targets[0].get("package-product-members", [])]
        if ("MHPlatform" in products) != (name == "Incomes"):
            raise ValueError("Incomes must be the only target adopting the MHPlatform umbrella product.")


def main() -> None:
    action, repository, *arguments = sys.argv[1:]
    _, configuration = load_project(Path(repository))
    if action == "swiftlint" and not arguments:
        remote_package(configuration, SWIFTLINT_REMOTE)
    elif action == "mhplatform" and len(arguments) == 1:
        check_mhplatform(configuration, arguments[0])
    else:
        raise ValueError("Unsupported project configuration check.")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError, TypeError, AttributeError, subprocess.SubprocessError) as error:
        print("Project configuration check incomplete: " + str(error), file=sys.stderr)
        raise SystemExit(2)
