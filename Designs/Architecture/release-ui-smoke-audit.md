# Release UI Smoke Audit

## Purpose

Release UI smoke auditing is a release-time visual confidence pass for the
real app running in Simulator. It complements the repository's build and
shared-library test posture without replacing it.

Use this audit to catch issues that library tests and app builds cannot see:

- launch failures
- blank or frozen primary screens
- unreachable core navigation
- obvious clipping, overlap, or unreadable text
- broken sheets, popovers, sidebars, and split-view layouts
- simulator-only coverage gaps that need human follow-up

## Relationship to Verification

The standard completion gate remains:

```sh
bash ci_scripts/tasks/verify_task_completion.sh
```

That gate verifies repository health through environment checks, SwiftLint,
the required app build, and `IncomesLibrary` tests. Release UI smoke auditing
is separate from that gate and should not be added to the normal task
completion flow by default.

## Workflow

Use the global `$xcode-ui-smoke-auditor` skill when performing this audit.
The skill owns the XcodeBuildMCP details for building, launching, inspecting
the live UI hierarchy, capturing screenshots, and reporting findings.

The repository expectation is:

1. Run the normal verification gate for code readiness.
2. Run release UI smoke only when preparing a release or when a UI-sensitive
   change needs live Simulator evidence.
3. Prefer representative iPhone and iPad Simulator coverage when available.
   For iPad, treat landscape as the representative layout because sidebar and
   split-view behavior are core release surfaces.
4. Treat the Apple Watch app as companion target coverage. Audit it when the
   available tool surface supports watchOS Simulator inspection; otherwise,
   report it as a coverage gap with the concrete blocker.
5. Keep screenshots and findings in the audit report, not as committed test
   artifacts.
6. Treat skipped targets and state-dependent coverage as explicit coverage
   gaps.

## Safety Rules

Release UI smoke auditing is non-destructive by default.

- Do not erase simulators, delete app data, reset keychains, or wipe
  containers unless explicitly requested.
- Do not perform purchases, account actions, sends, deletes, or other
  externally visible actions.
- Do not add UI test targets, snapshot tests, accessibility identifiers, or
  debug routes solely as part of the audit.
- Use repository-provided debug or sample data flows only when they are
  clearly safe.
- If deterministic state is needed, prefer debug-only launch arguments that do
  not remove existing data.

## Reporting

Reports should be evidence-backed and concise. Use the structure from
`$xcode-ui-smoke-auditor`:

1. `blocking issues`
2. `warnings`
3. `notes`
4. `coverage gaps`
5. `screenshots`
6. `session defaults`

When no issue is found, state that no blocking issue was observed in the
audited coverage and still list remaining gaps.
