#!/usr/bin/env python3
"""Match a private verification receipt to Git's proposed branch updates.

This pilot checks evidence references and scope, not evidence authenticity.
It executes no build, scanner, network operation, or repository check.
"""
from __future__ import annotations

import hashlib
import json
from pathlib import Path
import re
import os
import shutil
from urllib.parse import urlparse
import subprocess
import sys


class IncompleteVerification(Exception):
    """The proposed update has no matching, complete verification receipt."""


def require(condition: object, message: str) -> None:
    if not condition:
        raise IncompleteVerification(message)


def git_environment() -> dict[str, str]:
    environment = {key: value for key, value in os.environ.items() if not key.startswith("GIT_")}
    environment.update(GIT_CONFIG_GLOBAL=os.devnull, GIT_CONFIG_SYSTEM=os.devnull,
                       GIT_CONFIG_NOSYSTEM="1", GIT_NO_REPLACE_OBJECTS="1",
                       GIT_NO_LAZY_FETCH="1", GIT_TERMINAL_PROMPT="0")
    return environment


def publication_preflight(remote_name: str, remote_location: str) -> None:
    require(bool(remote_name and remote_location), "The publication destination is missing.")
    destinations = subprocess.run(["git", "remote", "get-url", "--push", "--all", remote_name],
                                  capture_output=True, text=True)
    explicit_url = remote_name == remote_location and (
        (urlparse(remote_location).scheme in {"https", "ssh"} and urlparse(remote_location).hostname)
        or remote_location.startswith("git@") and ":" in remote_location
    )
    require((destinations.returncode == 0 and remote_location in destinations.stdout.splitlines()) or explicit_url,
            "The destination is not a configured push location or an explicit Git URL.")
    require(git("rev-parse", "--is-shallow-repository") == "false",
            "Shallow history cannot establish complete outgoing publication coverage.")
    common = Path(git("rev-parse", "--path-format=absolute", "--git-common-dir"))
    partial = subprocess.run(["git", "config", "--local", "--get-regexp",
                              r"^(extensions\.partialclone|remote\..*\.promisor)$"],
                             capture_output=True, env=git_environment())
    require(partial.returncode == 1 and not any((common / "objects" / "pack").glob("*.promisor"))
            and not (common / "info" / "grafts").exists(),
            "Incomplete or rewritten local history needs a complete snapshot first.")
    binary = shutil.which("betterleaks")
    require(binary, "Betterleaks is missing from PATH; publication verification is incomplete.")
    result = subprocess.run([binary, "version"], capture_output=True, text=True, timeout=30)
    require(result.returncode == 0 and result.stdout.strip() == "1.9.0",
            "Unsupported Betterleaks version; review the adapter before upgrading.")


def current_quality_environment() -> dict[str, str]:
    values = {}
    for name, argv in (("xcodebuild", ["xcrun", "xcodebuild", "-version"]),
                       ("swift", ["xcrun", "swift", "--version"])):
        result = subprocess.run(argv, capture_output=True, text=True, timeout=30)
        require(result.returncode == 0 and result.stdout.strip(), "The current Apple toolchain is unavailable.")
        values[name] = result.stdout.strip()
    return values


def git(*args: str) -> str:
    result = subprocess.run(["git", *args], capture_output=True, text=True, env=git_environment())
    require(result.returncode == 0, "Required Git object or repository metadata is unavailable.")
    return result.stdout.strip()


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def private_file(store: Path, name: object) -> Path:
    require(isinstance(name, str) and bool(name), "An evidence path is missing.")
    relative = Path(name)
    require(not relative.is_absolute() and ".." not in relative.parts, "Evidence must stay in the private receipt store.")
    path = store / relative
    require(all(not part.is_symlink() for part in (path, *path.parents) if part != store.parent),
            "Symlinked evidence is not accepted.")
    require(path.is_file() and path.resolve().is_relative_to(store), "A regular private evidence file is missing.")
    return path


def load_object(path: Path) -> dict:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        raise IncompleteVerification("An evidence JSON record is unreadable.") from None
    require(isinstance(value, dict), "An evidence JSON record is not an object.")
    return value


def passed_record(store: Path, relative: object) -> dict:
    path = private_file(store, relative)
    record = load_object(path)
    require(record.get("schema_version") == 1, "Unsupported verification evidence version.")
    verification = record.get("verification", {})
    require(verification.get("ran") is True and verification.get("status") == "passed"
            and type(verification.get("exit_code")) is int and verification.get("exit_code") == 0
            and isinstance(verification.get("argv"), list) and verification.get("argv"),
            "A required check was not executed successfully.")
    require(not record.get("evidence_errors"), "Verification evidence has unresolved errors.")
    diagnostics = record.get("diagnostics", {})
    require(diagnostics.get("complete_captured_output") is True,
            "Captured diagnostic output is incomplete.")
    require(type(diagnostics.get("warning_count")) is int and type(diagnostics.get("error_count")) is int
            and diagnostics.get("warning_count") == 0 and diagnostics.get("error_count") == 0
            and diagnostics.get("warnings") == [] and diagnostics.get("errors") == [],
            "A required check contains errors or warnings.")
    artifacts = record.get("artifacts")
    require(isinstance(artifacts, list) and bool(artifacts), "Raw tool output is missing.")
    for artifact in artifacts:
        require(isinstance(artifact, dict), "Malformed tool-output reference.")
        file = private_file(store, str(path.parent.relative_to(store) / artifact.get("path", "")))
        require(digest(file.read_bytes()) == artifact.get("sha256"), "Tool output changed after verification.")
    return record


def native_quality_record(store: Path, relative: str, record: dict, kind: str) -> None:
    require(record.get("producer") == "ci-verify-xcode-result-review"
            and record.get("native", {}).get("complete_scope") is True,
            "Complete producing native Xcode evidence is required for build and tests.")
    directory = Path(relative).parent
    artifacts = {entry["path"] for entry in record["artifacts"]}
    require("native-build.json" in artifacts and "original-result.json" in artifacts,
            "Native export and original execution references are missing.")
    native_build = load_object(private_file(store, str(directory / "native-build.json")))
    original = load_object(private_file(store, str(directory / "original-result.json")))
    require(native_build == record["native"].get("build") and native_build.get("status") == "succeeded"
            and all(native_build.get(key) == 0 for key in ("errorCount", "warningCount", "analyzerWarningCount"))
            and all(native_build.get(key) == [] for key in ("errors", "warnings", "analyzerWarnings"))
            and original.get("verification", {}).get("ran") is True
            and original["verification"].get("exit_code") == 0
            and original.get("source") == record.get("source")
            and original.get("environment") == record.get("environment")
            and original["verification"].get("argv") == record["verification"]["argv"],
            "Native exports or producing execution do not match the quality record.")
    expected = record["diagnostics"].get("expected_test_output", [])
    require(record["diagnostics"].get("expected_test_output_count", 0) == len(expected)
            and original.get("diagnostics", {}).get("error_count") == len(expected)
            and original["diagnostics"].get("warning_count") == 0,
            "Captured diagnostic candidates lack complete explicit classification.")
    if expected:
        require("expected-test-output-review.json" in artifacts,
                "The exact negative-test diagnostic review is missing.")
        review = load_object(private_file(store, str(directory / "expected-test-output-review.json")))
        require(review.get("errors") == expected and review.get("source_head") == record["source"]["before"]["head"],
                "Expected diagnostic review changed or belongs to a different source.")
    argv = record["verification"]["argv"]
    require(argv.count("-scheme") == 1 and argv[argv.index("-scheme") + 1] ==
            ("Incomes" if kind == "build" else "IncomesLibrary"),
            "The required app or library scheme was not verified.")
    if kind == "tests":
        require("native-tests.json" in artifacts and "native-test-tree.json" in artifacts
                and "-testPlan" in argv and argv[argv.index("-testPlan") + 1] == "IncomesLibrary"
                and not any(word.startswith(("-only-testing", "-skip-testing")) for word in argv),
                "Complete IncomesLibrary test-plan execution is required.")
        summary = load_object(private_file(store, str(directory / "native-tests.json")))
        tree = load_object(private_file(store, str(directory / "native-test-tree.json")))
        bundles = {}
        def visit(node):
            if node.get("nodeType") == "Unit test bundle":
                bundles[node.get("name")] = node.get("result")
            for child in node.get("children", []):
                visit(child)
        for node in tree.get("testNodes", []):
            visit(node)
        require(summary == record["native"].get("tests") and summary.get("result") == "Passed"
                and summary.get("passedTests") == record.get("tests", {}).get("executed")
                and summary.get("passedTests") == summary.get("totalTestCount")
                and all(summary.get(key) == 0 for key in ("failedTests", "skippedTests", "expectedFailures"))
                and summary.get("runtimeWarnings") == [] and summary.get("testFailures") == []
                and bundles == record["native"].get("test_targets")
                and all(bundles.get(name) == "Passed" for name in
                        ("IncomesLibraryTests", "IncomesLibraryTimeZoneTests")),
                "Required native test bundles, issues or counts are unresolved.")


def lint_quality_record(store: Path, relative: str, record: dict) -> None:
    require(record.get("producer") == "ci-verify-and-summarize"
            and record["verification"]["argv"] == ["bash", "ci_scripts/tasks/check_repository_rules.sh"],
            "Complete repository rules execution is required for lint evidence.")
    directory = Path(relative).parent
    require(any(a["path"] == "output.log" for a in record["artifacts"]), "Lint output is missing.")
    lines = private_file(store, str(directory / "output.log")).read_text(encoding="utf-8").splitlines()
    proofs = [json.loads(line.removeprefix("SwiftLint execution: ")) for line in lines
              if line.startswith("SwiftLint execution: ")]
    require(len(proofs) == 1 and lines.count("Repository rules check passed.") == 1,
            "Lint lacks one completed SwiftLint execution and repository rule result.")
    proof = proofs[0]
    head = record["source"]["before"]["head"]
    def file_hash(path):
        result = subprocess.run(["git", "show", head + ":" + path], capture_output=True, env=git_environment())
        require(result.returncode == 0, "A lint input is missing from its source commit.")
        return digest(result.stdout)
    files = git("ls-tree", "-r", "--name-only", head, "--").splitlines()
    files = [path for path in files if path.endswith(".swift")]
    binary = proof.get("binary", "")
    require(proof.get("schema_version") == 1 and proof.get("mode") == "lint"
            and proof.get("exit_code") == 0 and proof.get("source_head") == head
            and proof.get("project_sha256") == file_hash("Incomes.xcodeproj/project.pbxproj")
            and proof.get("config_sha256") == file_hash(".swiftlint.yml")
            and proof.get("files") == files and bool(files)
            and proof.get("argv") == [binary, "lint", "--quiet", "--no-cache", "--strict", *files]
            and binary.endswith("/artifacts/swiftlintplugins/SwiftLintBinary/SwiftLintBinary.artifactbundle/macos/swiftlint")
            and proof.get("package_remote") == "https://github.com/SimplyDanny/SwiftLintPlugins"
            and proof.get("version") == proof.get("package_version")
            and bool(re.fullmatch(r"\d+\.\d+\.\d+", proof.get("version", "")))
            and all(re.fullmatch(r"[0-9a-f]{64}", proof.get(key, "")) for key in
                    ("binary_sha256", "package_manifest_sha256", "workspace_state_sha256", "artifact_checksum"))
            and bool(re.fullmatch(r"[0-9a-f]{40}", proof.get("package_revision", ""))),
            "SwiftLint execution, actual binary/version, or source inputs do not match lint evidence.")


def input_reuse_allowed(before: str, after: str) -> bool:
    # These prose-only paths are not build/test/lint inputs in the Incomes pilot.
    # Keep resources, generated docs, project files, scripts, and configuration out.
    ancestor = subprocess.run(["git", "merge-base", "--is-ancestor", before, after], capture_output=True, env=git_environment())
    if ancestor.returncode != 0:
        return False
    paths = git("diff", "--name-only", "--no-ext-diff", "--no-textconv", before, after, "--").splitlines()
    return all(path == "README.md" or (path.startswith("Designs/") and path.endswith(".md")) for path in paths)


def source_matches(record: dict, target: str, tree: str, reused: bool) -> None:
    source = record.get("source", {})
    before = source.get("before", {})
    after = source.get("after", {})
    require(source.get("stable_clean_snapshot") is True and before == after and before.get("clean") is True,
            "A check did not use a stable clean source snapshot.")
    old = before.get("head", "")
    require(bool(re.fullmatch(r"[0-9a-f]{40}|[0-9a-f]{64}", old)), "Evidence source OID is missing.")
    require(before.get("tree") == git("rev-parse", old + "^{tree}"), "Evidence source tree does not match its commit.")
    if reused:
        require(input_reuse_allowed(old, target), "Reused evidence has changed build/test/lint inputs.")
    else:
        require(old == target and before.get("tree") == tree, "Quality evidence belongs to a different commit.")


def proposed_updates(lines: str) -> list[dict[str, str]]:
    updates = []
    for line in lines.splitlines():
        parts = line.split()
        require(len(parts) == 4, "Malformed pre-push input.")
        local_ref, local_oid, remote_ref, remote_oid = parts
        require(all(re.fullmatch(r"[0-9a-f]{40}|[0-9a-f]{64}", oid) for oid in [local_oid, remote_oid]),
                "A push object ID is invalid.")
        require(set(local_oid) != {"0"}, "Ref deletion is outside the verification pilot.")
        require(remote_ref.startswith("refs/heads/") and
                subprocess.run(["git", "check-ref-format", remote_ref], capture_output=True,
                               env=git_environment()).returncode == 0,
                "The pilot supports valid branch refs; other publication needs separate review.")
        require(local_ref == local_oid or
                ((local_ref == "HEAD" or local_ref.startswith("refs/heads/")) and
                 git("rev-parse", "--verify", local_ref + "^{commit}") == local_oid),
                "The source ref does not resolve to the proposed immutable commit.")
        git("cat-file", "-e", local_oid + "^{commit}")
        if set(remote_oid) != {"0"}:
            git("cat-file", "-e", remote_oid + "^{commit}")
            require(subprocess.run(["git", "merge-base", "--is-ancestor", remote_oid, local_oid],
                                   capture_output=True, env=git_environment()).returncode == 0,
                    "Non-fast-forward publication is outside the verification pilot.")
        updates.append(dict(local_ref=local_ref, local_oid=local_oid,
                            remote_ref=remote_ref, remote_oid=remote_oid))
    require(len({item["remote_ref"] for item in updates}) == len(updates), "Duplicate destination refs.")
    return sorted(updates, key=lambda item: item["remote_ref"])


def outgoing_commits(updates: list[dict[str, str]]) -> list[str]:
    commits = set()
    for item in updates:
        args = ["rev-list", item["local_oid"]]
        if set(item["remote_oid"]) != {"0"}:
            args.extend(["--not", item["remote_oid"]])
        commits.update(git(*args).splitlines())
    return sorted(commits)


def check(remote_name: str, remote_location: str, lines: str) -> list[str]:
    if not lines.strip():
        return []
    publication_preflight(remote_name, remote_location)
    updates = proposed_updates(lines)
    common = Path(git("rev-parse", "--path-format=absolute", "--git-common-dir")).resolve()
    store = common / "push-verification"
    require(store.is_dir() and not store.is_symlink(), "No push-verification receipt: ask the agent to verify the intended push first.")
    receipt_path = "destinations/" + digest(remote_location.encode()) + "/receipt.json"
    receipt = load_object(private_file(store, receipt_path))
    require(receipt.get("schema_version") == 2, "Unsupported push receipt version.")
    require(receipt.get("common_git_dir") == str(common), "Receipt belongs to a different repository.")
    require(receipt.get("destination") == {"remote_name": remote_name,
                                           "location_sha256": digest(remote_location.encode())},
            "The push destination does not match the review.")
    expected = receipt.get("updates")
    require(isinstance(expected, list) and sorted(expected, key=lambda item: item.get("remote_ref", "")) == updates,
            "The source SHA, refs, or destination base changed after review.")
    reviewed = outgoing_commits(updates)
    publication = receipt.get("publication", {})
    require(publication.get("commits") == reviewed, "Outgoing history changed or was not fully reviewed.")
    require(not publication.get("uninspected"), "Outgoing artifacts remain uninspected.")
    mechanical = publication.get("mechanical", {})
    require(mechanical.get("status") == "passed" and mechanical.get("commits") == reviewed,
            "The outgoing-history secret scan is missing or covers a different history.")
    require(mechanical.get("scanner") == "betterleaks" and mechanical.get("scanner_version") == "1.9.0",
            "This receipt requires supported passive Betterleaks evidence; another engine is not equivalent.")
    scans = mechanical.get("scans")
    require(isinstance(scans, list) and len(scans) == len(updates),
            "Every proposed ref needs matching mechanical scan evidence.")
    scan_updates = []
    scanned_commits = set()
    for scan in scans:
        require(isinstance(scan, dict) and scan.get("update") in updates,
                "A scanner range does not match the proposed updates.")
        update = scan["update"]
        scan_updates.append(update)
        execution = passed_record(store, scan.get("evidence"))
        report = private_file(store, scan.get("report"))
        require(digest(report.read_bytes()) == scan.get("sha256"), "The scanner report changed after review.")
        findings = load_object(report)
        base = None if set(update["remote_oid"]) == {"0"} else update["remote_oid"]
        expected_commits = outgoing_commits([update])
        require(findings.get("status") == "clean" and findings.get("findings") == []
                and findings.get("scanner") == "betterleaks" and findings.get("scanner_version") == "1.9.0"
                and findings.get("validation") is False and findings.get("head") == update["local_oid"]
                and findings.get("base") == base and findings.get("new_ref") is (base is None)
                and findings.get("commits") == expected_commits,
                "The scanner report has findings or unsupported coverage; review and resolve it.")
        argv = execution["verification"]["argv"]
        def option_value(option):
            require(argv.count(option) == 1 and argv.index(option) + 1 < len(argv),
                    "Recorded scanner options are incomplete or duplicated.")
            return argv[argv.index(option) + 1]
        require(any(Path(word).name == "publication_tools.py" for word in argv)
                and argv.count("scan") == 1 and option_value("--head") == update["local_oid"]
                and Path(option_value("--report")).name == report.name
                and ((base is None and argv.count("--new-ref") == 1 and "--base" not in argv) or
                     (base is not None and "--new-ref" not in argv and option_value("--base") == base)),
                "Recorded scanner execution does not match the immutable range.")
        scanned_commits.update(expected_commits)
    require(sorted(scan_updates, key=lambda item: item["remote_ref"]) == updates
            and sorted(scanned_commits) == reviewed,
            "Mechanical scans omit or duplicate outgoing ref/history coverage.")
    contextual = publication.get("contextual", {})
    require(contextual.get("status") == "passed" and contextual.get("commits") == reviewed,
            "Contextual publication review is missing or covers a different history.")
    review_file = private_file(store, contextual.get("report"))
    require(review_file.stat().st_size > 0 and digest(review_file.read_bytes()) == contextual.get("sha256"),
            "The contextual review record is missing or changed.")
    quality = receipt.get("quality", {})
    current_environment = current_quality_environment()
    for item in updates:
        target = item["local_oid"]
        tree = git("rev-parse", target + "^{tree}")
        target_record = quality.get(target, {})
        require(target_record.get("tree") == tree and target_record.get("environment"),
                "The sent commit lacks matching tree/environment quality evidence.")
        require(all(target_record["environment"].get(key) == value
                    for key, value in current_environment.items()),
                "The current Apple toolchain changed after verification.")
        checks = target_record.get("checks", {})
        paths = []
        for kind in ["build", "tests", "lint"]:
            entry = checks.get(kind, {})
            require(entry.get("status") in {"passed", "reused"} and entry.get("scope"),
                    f"Required {kind} evidence is missing.")
            record = passed_record(store, entry.get("evidence"))
            source_matches(record, target, tree, entry["status"] == "reused")
            if kind in {"build", "tests"}:
                native_quality_record(store, entry["evidence"], record, kind)
            else:
                lint_quality_record(store, entry["evidence"], record)
            require(record.get("environment") == target_record["environment"],
                    "Check environments differ; reassess evidence reuse.")
            if kind == "tests":
                counts = record.get("tests", {})
                require(type(counts.get("executed")) is int and counts["executed"] > 0
                        and counts.get("failed") == 0 and counts.get("skipped") == 0 and entry.get("skipped") == 0,
                        "Required test execution, failures, or skips are unresolved.")
            paths.append(entry["evidence"])
        diagnostic_check = checks.get("diagnostics", {})
        require(diagnostic_check.get("status") == "passed"
                and sorted(diagnostic_check.get("evidence", [])) == sorted(set(paths))
                and diagnostic_check.get("scope"),
                "Error/warning review must cover all required tool results.")
    return reviewed


def main() -> int:
    if len(sys.argv) != 3:
        print("Usage: python3 check_push_verification.py <remote-name> <remote-location>", file=sys.stderr)
        return 2
    try:
        reviewed = check(sys.argv[1], sys.argv[2], sys.stdin.read())
    except (IncompleteVerification, OSError, TypeError, KeyError, AttributeError, ValueError, subprocess.TimeoutExpired):
        error = sys.exc_info()[1]
        message = str(error) if isinstance(error, IncompleteVerification) else "Malformed or unreadable verification evidence."
        print("Push verification incomplete: " + message, file=sys.stderr)
        return 1
    print(f"Push verification scope matches ({len(reviewed)} outgoing commits). Evidence authenticity and contextual disclosure safety are not independently proved.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
