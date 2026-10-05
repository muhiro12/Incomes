# Push Verification Pilot

The agent prepares and reviews evidence before a meaningful push. A thin local
pre-push hook then compares that private evidence with every proposed branch
update. It runs no build, lint, scanner, network request, or installation. It
probes the current scanner version and Apple toolchain to reject stale evidence.

The five requirements are actual app build success, zero real errors/warnings,
successful full library tests, successful lint/static rules, and no unresolved
publication findings. Small commits do not trigger this aggregate procedure.
Xcode Cloud remains responsible for formal builds, tests, archives, and upload
after sharing; it cannot prevent disclosure on the initial push.

## Prepare Actual Evidence

Follow the root README's Build and Test contract. Use a clean committed source
snapshot, selected Xcode, assigned Simulator, resolved dependency pins, full
`IncomesLibrary` test plan, and normal `Incomes` consumer build. An isolated
checkout can verify an intended OID without touching another task's worktree.
Keep formatting separate from final lint; fixtures are not application evidence.

Use the existing `ci-verify-and-summarize` skill's execution helper to retain full
output, actual argv/exit, source OID/tree, and environment. For official Xcode CLI
fallbacks, retain an explicit new result bundle, then use its
`review_xcode_evidence.py` adapter. See that skill's
`references/xcode-result-review.md` for complete native export, exact negative-test
review, and optional owned-fixture cleanup. Build evidence must select `Incomes`;
tests must select `IncomesLibrary` and its full plan, with both
`IncomesLibraryTests` and `IncomesLibraryTimeZoneTests` passed. Partial-test flags,
missing exports, native/captured warnings, failures, and skips do not clear QA.

The library/test route currently has no App Intents implementation. Its CLI test
invocation uses `LM_SKIP_METADATA_EXTRACTION=YES` to omit irrelevant metadata
extraction, following Apple's task producer. Reassess that setting if the library
adopts App Intents. The normal app build retains metadata extraction. Quiet-warning
options are not used. Deliberate read-only save/migration and corrupt-store logs
require exact, source-bound review against passed native negative tests; original
logs and candidate counts remain retained. Persistent test DB roots stay alive
until test-process exit and are cleaned only by their exact emitted paths after
the assigned Simulator stops; Simulator may already have removed them.

## Publication and Private Receipt

The shared `git-publication-review` skill owns portable rg/Betterleaks setup and
passive outgoing-history scanning. Check its README/setup reference on each host;
do not rely on a Codex application bundle or silently replace an absent tool.
This adapter supports Betterleaks **1.9.0**. Another version requires an explicit
adapter review. Validation of possible credentials is disabled; reports are
redacted. A clean scan does not replace contextual review of private information,
commit metadata, binaries, LFS pointers, submodules, and scanner exclusions.

Freshly observe all intended destinations, visibility, and refs before reviewing.
Every branch contributes all commits reachable from its proposed new OID but
not its observed old OID, including merge side history and added-then-removed
content. A new branch conservatively requires its full history. Review all push
URLs and default-added refs; a final-tree diff or stale tracking ref is insufficient.

Resolve the store with `git rev-parse --path-format=absolute --git-common-dir`.
Keep evidence under its private `push-verification/` directory. Receipt paths are
`destinations/<SHA256-of-exact-push-location>/receipt.json`; artifacts are relative
to the store. Each destination has a separate receipt. Never store credential-bearing
URLs in a receipt. The version-2 fields are:

- `schema_version`: `2`; `common_git_dir`: resolved repository identity.
- `destination`: `remote_name` and exact `location_sha256` supplied by Git.
- `updates`: every full `local_ref`, `local_oid`, `remote_ref`, and `remote_oid`
  from Git's pre-push stdin. Each local ref must resolve to that immutable OID.
- `quality`: keyed by every sent OID, with tree, recorded environment, and
  `checks` for `build`, `tests`, `lint`, and `diagnostics`. Check entries have
  `passed`/`reused`, relative `result.json` evidence, and scope. Tests also require
  `skipped: 0`. Diagnostics reference the complete set of those three records.
  Build/tests require hash-bound original execution and full native exports from
  the shared adapter; lint retains its actual full output. Related environments
  must match each other and the current Xcode/Swift probes.
- `publication`: sorted full outgoing `commits`, empty `uninspected`, and separate
  `mechanical` and `contextual` records covering that exact union. Mechanical has
  `status: passed`, `scanner: betterleaks`, `scanner_version: 1.9.0`, `commits`,
  and a `scans` array with exactly one entry per update: exact `update`, actual
  execution `evidence`, safe JSON `report`, and its `sha256`. Each report and argv
  must match `publication_tools.py scan` and that immutable base/head or new-ref
  range. Contextual has `status: passed`, `commits`, private report and `sha256`.

Execution records remain schema version 1. Missing, changed, malformed, failed,
symlinked, unexecuted, stale, or differently scoped evidence blocks the update.
Version-1 Gitleaks receipts are incompatible and must be regenerated. Never
relabel another scanner's summary or fabricate native success.

## Scope, Reuse, and Hook Recovery

The pilot supports fast-forward and new branch updates. Force updates, deletion,
tags, shallow/partial/grafted histories, and unsupported tools need separate
review. Multiple refs must all match and have QA. Each destination invocation
is checked independently; Git publication across destinations is not atomic.
Other hosts, provider API writes, bypass, and clients that do not invoke this
Git process/effective hook are outside its coverage.

Quality can be reused from an ancestor only for changes limited to `README.md`
and Markdown under `Designs/`, which are not current build/test/lint inputs.
Resources, project files, locks, scripts, tests, and generated docs invalidate
reuse. New outgoing history and metadata always require new publication review.

The Incomes-only hook changes directory to the repository root and executes
`python3 ci_scripts/tasks/check_push_verification.py <remote-name> <remote-location>`
with Git's exact stdin. Retained static rules run during evidence preparation;
the hook does not repeat them. Before activation, require real application QA
and an end-to-end pass with matching actual evidence plus failing-case fixtures.

Retain installed hook bytes, hash, and executable mode privately before replacing
it. Compare the current hash before installation; leave global `core.hooksPath`
alone. For recovery, compare against the installed hash before restoring saved
bytes/mode so later work is not overwritten. Hooks and receipts are local;
cloning the repository does not install them.

Hashes/OIDs detect missing or mismatched evidence, not execution authenticity
against the same OS user. Clean mechanical/contextual reviews cannot prove the
absence of all private information. Persistent raw/serialized/OS contracts still
need semantic review; passing QA alone does not establish compatibility.
