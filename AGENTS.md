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

- Develop Incomes 6.x on `main`. The `5.12` tag preserves the released 5.x
  baseline; branch from it if a separate 5.x maintenance release is needed.
- Use Xcode 27 RC (27A266a) as the initial development and release toolchain
  for 6.x. Verify `xcode-select -p` and `xcodebuild -version` before Apple builds.
  Adopt the corresponding stable Xcode 27 release when available.
- Xcode 26 compatibility is not required for 6.x. Keep deployment-target
  availability checks; changing the toolchain does not raise the supported OS.
- The Xcode Cloud workflow targets `main` with **Latest Beta or Release**.
  Check the actual Xcode version in each candidate's build record and use
  that same version for local release verification; the rolling selection
  can change independently of the local installation.

## Release Tools

- Use the dedicated macOS package in `Tools/Release` for Apogee release
  operations. Pin an exact published version and retain `Package.resolved`.
- Keep Apogee out of the app, library, Watch, and Widgets dependency graphs.
- Follow `Tools/Release/README.md` for local validation, authentication, and
  staged App Store Connect operations. Start with read-only release status.
- Before remote writes, review the exact app, version, locales, and full dry-run
  diff. Keep credentials and remote plans outside tracked repository files.

## Build and Test Entry Point

Agents MUST prefer XcodeBuildMCP for Apple build, test, run, Simulator,
runtime log, screenshot, and UI snapshot verification.

Before the first XcodeBuildMCP build, test, or run call in a session, run
XcodeBuildMCP `session_show_defaults`. If defaults do not point at this
repository, set them for the current session before continuing.

If XcodeBuildMCP is unavailable, use the official Xcode integration or Apple
command-line tools for the same scheme and evidence, and report the fallback.

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
- For runtime or UI checks, do not disable code signing. The app needs signed
  App Group entitlements at launch, so reserve `CODE_SIGNING_ALLOWED=NO` for
  compile-only builds.

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
