# Push Verification Pilot

This pilot separates verification from the final Git scope check. The agent
runs and reviews the required checks before a meaningful push. A small local
pre-push check then compares the private evidence with every proposed branch
update. It performs no build, scan, network request, or automatic installation.

The five requirements are build success, zero errors and warnings in the
required diagnostic scope, test success, lint success, and no unresolved
publication findings. Small commits do not trigger this aggregate procedure.
Xcode Cloud remains responsible for formal builds, tests, archives, and upload
after the commit is shared; it cannot prevent disclosure on that initial push.

## Prepare Actual Evidence

Use the existing Build and Test contract in the root README to select library
tests and affected app, widget, watch, and consumer surfaces. Resolve the active
Xcode capabilities and restore any selection changed for verification. Do not
use a successful script or pilot fixture as evidence of an app build or library
test. Keep autofix separate from the final non-mutating lint check.

The `ci-verify-and-summarize` skill can retain actual command output:

```sh
bash /path/to/ci-verify-and-summarize/scripts/run_verify_and_summarize.sh \
  --evidence-dir /private/new-run-directory \
  --require-clean-diagnostics -- bash ci_scripts/tasks/check_repository_rules.sh
```

For a documented official-tool fallback, use `--tool` followed by its literal
argv instead of adding a shell wrapper. Include the selected scheme,
configuration, destination, test plan, result-bundle path, resolved dependencies,
and actual Xcode/SDK in the evidence context. Captured CLI output does not prove
that an integration exposed all native issues: inspect full native results and
required test coverage, including skips. The helper records every recognized
captured diagnostic, not just its short display samples.

Verification must correspond to a clean committed snapshot before and after
execution. If the current worktree contains separate uncommitted work, verify
the intended OID in an isolated snapshot. Do not stage, stash, or delete another
task's changes. A later HEAD does not invalidate an explicit earlier OID, but
new input changes invalidate the affected evidence.

## Private Receipt

Resolve the common Git directory with:

```sh
git rev-parse --path-format=absolute --git-common-dir
```

Store `push-verification/receipt.json`, evidence directories, a scanner JSON
report, and a contextual review there. Keep these out of committed files.
Evidence paths are relative to this store. Symlinked, missing, changed, malformed,
failed, and unexecuted evidence is rejected. Only the producing command can
supply its actual exit/output; an agent's summary is not a substitute.

The receipt's version-1 fields are:

- `schema_version`: `1`.
- `common_git_dir`: the resolved repository identity.
- `destination`: `remote_name` and `location_sha256`, the SHA-256 of the exact
  push location supplied by Git. Do not store credential-bearing remote URLs.
- `updates`: every `local_ref`, `local_oid`, `remote_ref`, and `remote_oid` from
  Git's pre-push stdin. Use full OIDs. The agent must review the intended
  destination's visibility, freshly observed refs, and any future publication.
- `quality`: keyed by every sent OID. Each entry has its tree OID, the recorded
  environment, and `checks` for `build`, `tests`, `lint`, and `diagnostics`.
  Build/tests/lint entries specify `passed` or `reused`, a relative `result.json`
  reference, and the reviewed scope. Tests require positive execution, zero
  failures, and zero unresolved skips in both the tool record and entry.
  Diagnostics specify `passed`, scope, and the complete set of those evidence
  references. Each referenced record must have zero captured errors/warnings.
- `publication`: the sorted full outgoing commit list, empty `uninspected`,
  and separate `mechanical` and `contextual` records for that same commit list.
  Mechanical evidence includes `passed`, scanner/version, actual run evidence,
  a relative JSON report, and its hash. This initial pilot supports Gitleaks
  reports with no findings; a custom regex or unavailable scanner is not an
  equivalent pass. Contextual evidence includes `passed`, the private report
  path, and its hash. The agent must review private information, commit/tag
  metadata, relevant content, and unexpected binary/LFS/submodule disclosure.

The execution-record shape is described by the verification skill. Native
results must be exported with the same source/result/output references and
reviewed for their actual scope; connection/configuration alone is not evidence.
Do not create a passed native record when the result or required issues are
unavailable. Receipt entries require the same environment across the related
results; the agent must refresh the real SDK/toolchain/dependency context before
reusing them. The checker does not independently interrogate Xcode.

## History and Reuse

Each updated branch contributes all commits reachable from its new OID that are
not reachable from the observed old OID. Merge side histories are included.
A new branch conservatively requires its full reachable history. A secret added
and later removed still requires review. Stale tracking refs, final-tree diffs,
and first-parent summaries do not clear publication.

This initial pilot handles fast-forward branch updates and new branches.
Force updates, deletions, tags, and incomplete/shallow object histories are
outside the pilot and stop for a separate review. Multiple refs must all match
and have quality evidence. Additional refs introduced by defaults are not
silently accepted.

Build/test/lint evidence can be reused from an ancestor only when changes are
limited to `README.md` and Markdown under `Designs/`. These prose-only paths are
not inputs in the current Incomes build/test/lint contract. Resources, project
files, package locks, scripts, fixtures, and generated documentation are excluded.
Reassess this narrow allowlist if the architecture changes. New history and
metadata always need an updated publication review, even with an identical tree.
Do not synthesize a first baseline from old or missing results.

## Local Hook and Recovery

The Incomes-only pilot hook first runs:

```sh
python3 ci_scripts/tasks/check_push_verification.py <remote-name> <remote-location>
```

with the exact Git stdin. After a successful match it still runs the existing
`check_repository_rules.sh`. This preserves the previous rules; their repeated
cost has not yet been removed. Receipt absence stops before claiming readiness.
Manual push, Codex, and Claude use the same check when they invoke this local
Git process and effective hook. Provider API writes, other hosts, hook bypass,
and GUI clients using another implementation are not covered.

Before replacing an installed hook, retain its bytes, hash, and executable mode
outside tracked content. Install only in this repository after confirming the
current hash; do not change global `core.hooksPath`. To restore, first compare
against the installed pilot hash so later work is not overwritten, then restore
the saved file and mode. The checker and documentation are tracked; hook state
and receipts are local and are not installed by cloning the repository.

## Limits and Current Readiness

Matching OIDs, reports, and hashes detects missing evidence, scope confusion,
and changed outputs. It does not prove execution authenticity: the same OS
user can forge evidence or alter the checker. Neither a clean scanner report
nor contextual AI review proves that no private information exists. No signing
service or new monitoring framework is added.

The pilot's isolated fixtures are synthetic process checks. They are not app
builds, library tests, or real secret scans. A missing scanner, native result,
required test, or diagnostic coverage remains unavailable, so no complete
push-ready receipt may be issued until it is resolved. Persistent data recovery
and raw/serialized/OS contracts still need the relevant semantic review;
build/test/lint success alone cannot establish their compatibility.
