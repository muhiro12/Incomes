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
import subprocess
import sys


class IncompleteVerification(Exception):
    """The proposed update has no matching, complete verification receipt."""


def require(condition: object, message: str) -> None:
    if not condition:
        raise IncompleteVerification(message)


def git(*args: str) -> str:
    result = subprocess.run(["git", *args], capture_output=True, text=True)
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


def input_reuse_allowed(before: str, after: str) -> bool:
    # These prose-only paths are not build/test/lint inputs in the Incomes pilot.
    # Keep resources, generated docs, project files, scripts, and configuration out.
    ancestor = subprocess.run(["git", "merge-base", "--is-ancestor", before, after], capture_output=True)
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
        require(remote_ref.startswith("refs/heads/"), "The pilot supports branch updates; tag publication needs separate review.")
        git("cat-file", "-e", local_oid + "^{commit}")
        if set(remote_oid) != {"0"}:
            git("cat-file", "-e", remote_oid + "^{commit}")
            require(subprocess.run(["git", "merge-base", "--is-ancestor", remote_oid, local_oid],
                                   capture_output=True).returncode == 0,
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
    updates = proposed_updates(lines)
    if not updates:
        return []
    require(git("rev-parse", "--is-shallow-repository") == "false",
            "Shallow history cannot establish complete outgoing publication coverage.")
    common = Path(git("rev-parse", "--path-format=absolute", "--git-common-dir")).resolve()
    store = common / "push-verification"
    require(store.is_dir() and not store.is_symlink(), "No push-verification receipt: ask the agent to verify the intended push first.")
    receipt = load_object(private_file(store, "receipt.json"))
    require(receipt.get("schema_version") == 1, "Unsupported push receipt version.")
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
    require(mechanical.get("scanner") == "gitleaks" and mechanical.get("scanner_version"),
            "This pilot requires recorded Gitleaks history-scan evidence; custom regex is not equivalent.")
    passed_record(store, mechanical.get("evidence"))
    scan_report = private_file(store, mechanical.get("report"))
    require(digest(scan_report.read_bytes()) == mechanical.get("sha256"), "The scanner report changed after review.")
    try:
        findings = json.loads(scan_report.read_text(encoding="utf-8"))
    except ValueError:
        raise IncompleteVerification("The scanner JSON report is unreadable.") from None
    require(isinstance(findings, list) and not findings,
            "The scanner report has findings or unsupported coverage; review and resolve it.")
    contextual = publication.get("contextual", {})
    require(contextual.get("status") == "passed" and contextual.get("commits") == reviewed,
            "Contextual publication review is missing or covers a different history.")
    review_file = private_file(store, contextual.get("report"))
    require(review_file.stat().st_size > 0 and digest(review_file.read_bytes()) == contextual.get("sha256"),
            "The contextual review record is missing or changed.")
    quality = receipt.get("quality", {})
    for item in updates:
        target = item["local_oid"]
        tree = git("rev-parse", target + "^{tree}")
        target_record = quality.get(target, {})
        require(target_record.get("tree") == tree and target_record.get("environment"),
                "The sent commit lacks matching tree/environment quality evidence.")
        checks = target_record.get("checks", {})
        paths = []
        for kind in ["build", "tests", "lint"]:
            entry = checks.get(kind, {})
            require(entry.get("status") in {"passed", "reused"} and entry.get("scope"),
                    f"Required {kind} evidence is missing.")
            record = passed_record(store, entry.get("evidence"))
            source_matches(record, target, tree, entry["status"] == "reused")
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
    except (IncompleteVerification, OSError, TypeError, KeyError, AttributeError, ValueError):
        error = sys.exc_info()[1]
        message = str(error) if isinstance(error, IncompleteVerification) else "Malformed or unreadable verification evidence."
        print("Push verification incomplete: " + message, file=sys.stderr)
        return 1
    print(f"Push verification scope matches ({len(reviewed)} outgoing commits). Evidence authenticity and contextual disclosure safety are not independently proved.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
