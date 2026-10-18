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

def load_project(repository: Path) -> tuple[Path, dict]:
    candidates = [repository / "Incomes.xcodeproj" / name for name in PROJECT_FILES]
    candidates = [path for path in candidates if path.is_file()]
    if len(candidates) != 1:
        raise ValueError("Incomes.xcodeproj must contain exactly one supported project configuration.")
    project = candidates[0]
    parsed = subprocess.run(["plutil", "-convert", "json", "-o", "-", str(project)],
                            check=True, capture_output=True)
    return project, summarize_project(json.loads(parsed.stdout), legacy=project.suffix == ".pbxproj")


def package_name(package: dict) -> str:
    location = package.get("repository", package.get("path", ""))
    return package.get("name", Path(location.rstrip("/")).stem)


def summarize_project(document: dict, *, legacy: bool = False) -> dict:
    """Keep declared products, their package owners, and actual Frameworks edges."""
    if not isinstance(document, dict):
        raise ValueError("The project configuration must be an object.")
    if not legacy:
        if "objects" in document:
            raise ValueError("A JSON project cannot use the legacy object model.")
        packages, targets = document["packages"], document["targets"]
        if not isinstance(packages, list) or not isinstance(targets, list):
            raise ValueError("The JSON project must declare packages and targets.")

        def product_for(member):
            package = None
            if "package" in member:
                matches = [value for value in packages if package_name(value) == member["package"]]
                if len(matches) != 1:
                    raise ValueError("The product must reference one declared package.")
                package = matches[0]
            return {"name": member["product-name"], "package": package}

        def framework_files(files, name):
            found = set()
            for file in files:
                path = Path(file.get("path", ""))
                for membership in file.get("target-membership", []):
                    phase = membership.get("build-phase") if isinstance(membership, dict) else membership
                    if phase == f"{name}/frameworks" or (phase == name and path.suffix == ".framework"):
                        found.add(path.stem)
                found.update(framework_files(file.get("children", []), name))
            return found

        result = []
        for target in targets:
            members = target.get("package-product-members", [])
            phases = [value.get("kind") if isinstance(value, dict) else value
                      for value in target.get("build-phases", [])]
            frameworks = []
            for member in members:
                phase = member.get("build-phase", {})
                phase = phase.get("build-phase") if isinstance(phase, dict) else phase
                if phase == "frameworks" and "frameworks" in phases:
                    frameworks.append(product_for(member))
            result.append({"name": target["name"], "members": [product_for(member) for member in members],
                           "frameworks": frameworks,
                           "files": framework_files(document.get("files", []), target["name"])})
        return {"packages": packages, "targets": result}

    objects = document["objects"]

    def object_for(identifier, kind):
        value = objects[identifier]
        if value.get("isa") != kind:
            raise ValueError(f"Invalid {kind} reference.")
        return value

    root = object_for(document["rootObject"], "PBXProject")
    references = root.get("packageReferences", [])

    def package_for(identifier):
        if identifier not in references:
            raise ValueError("The product must reference a project-owned package.")
        value = objects[identifier]
        if value.get("isa") == "XCRemoteSwiftPackageReference":
            requirement = value["requirement"]
            version = ({"up-to-next-major-version": requirement["minimumVersion"]}
                       if requirement.get("kind") == "upToNextMajorVersion" else {"unsupported": requirement})
            return {"kind": "remote", "repository": value["repositoryURL"], "version": version}
        if value.get("isa") == "XCLocalSwiftPackageReference":
            return {"kind": "local", "path": value["relativePath"]}
        raise ValueError("Invalid project package reference.")

    def product_for(identifier):
        value = object_for(identifier, "XCSwiftPackageProductDependency")
        return {"name": value["productName"],
                "package": package_for(value["package"]) if "package" in value else None}

    targets = []
    for identifier in root["targets"]:
        target = objects[identifier]
        if target.get("isa") != "PBXNativeTarget":
            continue
        frameworks, files = [], set()
        for phase_id in target.get("buildPhases", []):
            phase = objects[phase_id]
            if phase.get("isa") != "PBXFrameworksBuildPhase":
                continue
            for file_id in phase.get("files", []):
                build_file = object_for(file_id, "PBXBuildFile")
                if "productRef" in build_file:
                    frameworks.append(product_for(build_file["productRef"]))
                elif "fileRef" in build_file:
                    file = object_for(build_file["fileRef"], "PBXFileReference")
                    files.add(Path(file.get("path", file.get("name", ""))).stem)
        targets.append({"name": target["name"],
                        "members": [product_for(value) for value in target.get("packageProductDependencies", [])],
                        "frameworks": frameworks, "files": files})
    return {"packages": [package_for(value) for value in references], "targets": targets}


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
        target = targets[0]
        if name == "Incomes":
            for edge in ("members", "frameworks"):
                products = [value for value in target[edge] if value["name"] == "MHPlatform"]
                if len(products) != 1 or products[0]["package"] != reference:
                    raise ValueError("Incomes must declare and link the canonical MHPlatform product in Frameworks.")
        elif "MHPlatform" in ({value["name"] for value in target["members"] + target["frameworks"]} | target["files"]):
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
