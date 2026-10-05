#!/usr/bin/env python3
"""Select the project's registered SwiftLint artifact and record its execution."""
from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys

REMOTE = "https://github.com/SimplyDanny/SwiftLintPlugins"
MARKER = "SwiftLint execution: "


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def version_tuple(value: str) -> tuple[int, ...]:
    if not re.fullmatch(r"\d+\.\d+\.\d+", value):
        raise ValueError("Unsupported SwiftLint version.")
    return tuple(map(int, value.split(".")))


def select(repository: Path, roots: list[Path]) -> dict | None:
    project = repository / "Incomes.xcodeproj/project.pbxproj"
    parsed = subprocess.run(["plutil", "-convert", "json", "-o", "-", str(project)],
                            check=True, capture_output=True, text=True)
    objects = json.loads(parsed.stdout)["objects"]
    references = [v for v in objects.values() if v.get("isa") == "XCRemoteSwiftPackageReference"
                  and v.get("repositoryURL", "").removesuffix(".git") == REMOTE]
    if len(references) != 1:
        raise ValueError("The project must declare one canonical SwiftLintPlugins dependency.")
    requirement = references[0]["requirement"]
    if requirement.get("kind") != "upToNextMajorVersion":
        raise ValueError("Review the adapter for the project's SwiftLint version requirement.")
    minimum = version_tuple(requirement["minimumVersion"])
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
        if any(v["packageRef"]["location"].removesuffix(".git") != REMOTE for v in (dependency, artifact)):
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
        # A relocated cache is allowed; bind its canonical relative artifact, not stale absolute state paths.
        version = subprocess.check_output([str(binary), "version"], text=True).strip()
        if version != package_version:
            raise ValueError("The actual SwiftLint binary version differs from package resolution.")
        return {"binary": str(binary), "binary_sha256": sha256(binary), "version": version,
                "package_version": package_version, "package_revision": revision, "package_remote": REMOTE,
                "package_manifest_sha256": sha256(package / "Package.swift"),
                "workspace_state_sha256": sha256(workspace), "artifact_checksum": source["checksum"],
                "project_sha256": sha256(project), "source_packages": str(root), "override": bool(override)}
    if override:
        raise ValueError("CI_SWIFTLINT_BIN must name a registered artifact in the configured project package cache.")
    return None


def run(repository: Path, roots: list[Path], mode: str, files: list[str]) -> int:
    selected = select(repository, roots)
    if selected is None:
        raise ValueError("The project-managed SwiftLint artifact is missing.")
    flags = ["--strict"] if mode == "lint" else ["--fix", "--format"]
    argv = [selected["binary"], "lint", "--quiet", "--no-cache", *flags, *files]
    status = subprocess.run(argv, cwd=repository).returncode
    if status:
        return status
    if sha256(Path(selected["binary"])) != selected["binary_sha256"]:
        raise ValueError("The SwiftLint binary changed during execution.")
    selected.update(schema_version=1, mode=mode, argv=argv, exit_code=status, files=files,
                    source_head=subprocess.check_output(["git", "-C", str(repository), "rev-parse", "HEAD"], text=True).strip(),
                    config_sha256=sha256(repository / ".swiftlint.yml"))
    print(MARKER + json.dumps(selected, sort_keys=True))
    return 0


def main() -> int:
    # The shell owner supplies exactly the two configured project package roots.
    action, repository, source_packages, derived_packages, *args = sys.argv[1:]
    root = Path(repository).resolve()
    roots = [Path(source_packages), Path(derived_packages)]
    if action == "select" and not args:
        selected = select(root, roots)
        if selected is None:
            return 1
        print(selected["binary"])
        return 0
    if action == "run" and args and args[0] in {"lint", "format"}:
        return run(root, roots, args[0], args[1:])
    raise ValueError("Unsupported SwiftLint adapter invocation.")


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, KeyError, TypeError, subprocess.SubprocessError) as error:
        print("SwiftLint verification incomplete: " + str(error), file=sys.stderr)
        raise SystemExit(2)
