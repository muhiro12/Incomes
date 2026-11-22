#!/usr/bin/env python3
"""Locate the SwiftLint binary registered for this project."""
from __future__ import annotations

import json
import os
from pathlib import Path
import re
import subprocess
import sys

from project_configuration import SWIFTLINT_REMOTE, load_project, remote_package


def version_tuple(value: str) -> tuple[int, ...]:
    if not re.fullmatch(r"\d+\.\d+\.\d+", value):
        raise ValueError("Unsupported SwiftLint version.")
    return tuple(map(int, value.split(".")))


def select(repository: Path, roots: list[Path]) -> Path | None:
    _, configuration = load_project(repository)
    requirement = remote_package(configuration, SWIFTLINT_REMOTE).get("version", {})
    if set(requirement) != {"up-to-next-major-version"}:
        raise ValueError("Review the adapter for the project's SwiftLint version requirement.")
    minimum = version_tuple(requirement["up-to-next-major-version"])
    override = os.environ.get("CI_SWIFTLINT_BIN")
    for root in roots:
        root = root.resolve()
        binary = root / "artifacts/swiftlintplugins/SwiftLintBinary/SwiftLintBinary.artifactbundle/macos/swiftlint"
        if override and Path(override).resolve() != binary.resolve():
            continue
        if not binary.is_file():
            continue
        workspace = root / "workspace-state.json"
        state = json.loads(workspace.read_text())["object"]
        dependencies = [d for d in state["dependencies"] if d["packageRef"]["identity"] == "swiftlintplugins"]
        artifacts = [a for a in state["artifacts"] if a["packageRef"]["identity"] == "swiftlintplugins"
                     and a["targetName"] == "SwiftLintBinary"]
        if len(dependencies) != 1 or len(artifacts) != 1:
            raise ValueError("The selected cache lacks unambiguous SwiftLint package resolution.")
        dependency, artifact = dependencies[0], artifacts[0]
        if any(v["packageRef"]["location"].removesuffix(".git") != SWIFTLINT_REMOTE for v in (dependency, artifact)):
            raise ValueError("The selected SwiftLint package has a different source.")
        checkout = dependency["state"]["checkoutState"]
        package_version = checkout["version"]
        bundle = binary.parent.parent
        metadata = json.loads((bundle / "info.json").read_text())["artifacts"]["swiftlint"]
        if (metadata.get("type") != "executable" or metadata["version"] != package_version
                or not minimum <= version_tuple(package_version) < (minimum[0] + 1, 0, 0)
                or not any(v.get("path") == "macos/swiftlint" for v in metadata["variants"])
                or not os.access(binary, os.X_OK)):
            raise ValueError("The selected SwiftLint artifact does not match the package or project requirement.")
        package = root / "checkouts" / dependency["subpath"]
        manifest = (package / "Package.swift").read_text()
        source = artifact["source"]
        if source.get("type") != "remote" or source["url"] not in manifest or source["checksum"] not in manifest:
            raise ValueError("The selected SwiftLint artifact does not match the resolved package manifest.")
        revision = subprocess.check_output(["git", "-C", str(package), "rev-parse", "HEAD"], text=True).strip()
        if revision != checkout["revision"]:
            raise ValueError("The SwiftLint package checkout changed after resolution.")
        version = subprocess.check_output([str(binary), "version"], text=True).strip()
        if version != package_version:
            raise ValueError("The actual SwiftLint binary version differs from package resolution.")
        return binary
    if override:
        raise ValueError("CI_SWIFTLINT_BIN must name a registered artifact in the configured project package cache.")
    return None


def main() -> int:
    repository, source_packages, derived_packages = map(Path, sys.argv[1:])
    binary = select(repository, [source_packages, derived_packages])
    if binary is None:
        return 1
    print(binary)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, KeyError, TypeError, subprocess.SubprocessError) as error:
        print("SwiftLint verification incomplete: " + str(error), file=sys.stderr)
        raise SystemExit(2)
