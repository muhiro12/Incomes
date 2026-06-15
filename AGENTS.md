# AGENTS.md

Repository-specific agent contract for Incomes.

## Repository Rules

- Use English for branch names, code comments, documentation, and identifiers
  unless UI localization or legal content requires otherwise.
- Follow existing architecture and source style; keep changes small and
  repository-local.
- Markdown must follow
  <https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md>.
- Swift code must comply with the repository SwiftLint configuration.

## Toolchain Compatibility

- Treat the selected latest Xcode as the default local development toolchain.
- While the selected latest Xcode is newer than the current App Store
  submission toolchain, keep the current App Store Xcode buildable.
- Prefer latest SDK and API spelling in product code, then isolate older
  toolchain backports behind small support helpers with compiler and
  availability checks. Keep the latest branch first and the fallback explicit.
- For Foundation Models, Apple Intelligence, App Intents, widgets, build
  settings, and other beta-sensitive SDK surfaces, verify both the selected
  latest Xcode and the current App Store Xcode when changing implementation or
  interfaces.

## Build and Test Entry Point

Agents MUST prefer XcodeBuildMCP for Apple build, test, run, Simulator,
runtime log, screenshot, and UI snapshot verification.

Before the first XcodeBuildMCP build, test, or run call in a session, run
XcodeBuildMCP `session_show_defaults`. If defaults do not point at this
repository, set them for the current session before continuing.

Treat library tests, surface builds, and runtime/UI evidence as separate
verification capabilities. Choose the smallest set that proves the current
change, and prefer stronger evidence when public APIs, wire contracts,
SwiftData schema, app lifecycle wiring, or visible UI behavior are affected.

- For shared-library logic, model, or test changes, use XcodeBuildMCP
  `test_sim` with the `IncomesLibrary` scheme.
- For public `IncomesLibrary` APIs, `*Operations`, shared sync contracts,
  SwiftData schema, or adapter-facing contracts, also use XcodeBuildMCP
  `build_sim` with the `Incomes` scheme.
- For app compile checks, use XcodeBuildMCP `build_sim` with the `Incomes`
  scheme.
- For Watch or Widgets target changes, use XcodeBuildMCP `build_sim` with the
  `Watch` or `Widgets` scheme that matches the changed surface.
- For runtime or UI-sensitive changes, use XcodeBuildMCP `build_run_sim`,
  `launch_app_sim`, `snapshot_ui`, and `screenshot` as appropriate.

When Swift files are edited, agents should run:

``` sh
bash ci_scripts/tasks/format_swift.sh
```

Agents should also run the retained repository rule checks:

``` sh
bash ci_scripts/tasks/check_repository_rules.sh
```

`check_repository_rules.sh` runs SwiftLint plus repository-specific static
architecture checks that are not naturally covered by XcodeBuildMCP.
SwiftLint is resolved from the `SimplyDanny/SwiftLintPlugins` package declared
in `Incomes.xcodeproj`, not from a separately installed `swiftlint` binary.
Xcode Cloud owns formal CI builds, tests, and archives.

Helper scripts may write disposable cache data under `.build/ci/shared/`.

## Release UI Smoke Audit

Release UI smoke auditing is separate from the standard verification entrypoint.
Keep it non-destructive by default: do not erase simulator data, reset
containers, or add UI test targets solely for the audit unless explicitly
requested.
