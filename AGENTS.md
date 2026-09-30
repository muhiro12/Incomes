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

## SwiftData App Data Flow

- Use live `Item` and `Tag` models in SwiftUI. Independent collections use
  feature-owned `@Query`; selected models use typed environment propagation.
- Keep form drafts, snapshots, routes, and external representations as values
  with their own lifetimes. Durable writes enter public `*Operations`.
- Follow the read-ownership rules and justified query boundaries in
  [the architecture guide](Designs/Architecture/ARCHITECTURE_GUIDE.md#live-app-data-flow).

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

Prefer the active Xcode-native integration and official Apple tooling for
project discovery, build, test, run, runtime logs, Preview rendering, live UI
inspection, and screenshots. Resolve current actions from the available tool
inventory. If the integration cannot provide the required evidence, use Apple
command-line tools for the same scheme and destination and report the gap.

Before changing Xcode's active selection, discover the open projects, schemes,
and destinations, identify `Incomes.xcodeproj`, and record the original scheme
and destination. Switch only to discovered values. End interaction sessions
and stop runs started solely for verification. Restore the original scheme
first, rediscover its valid destinations, restore the original destination,
and confirm the final selection. Report any selection that cannot be restored.

Treat library tests, surface builds, and runtime/UI evidence as separate
verification capabilities. Choose the smallest set that proves the current
change, and prefer stronger evidence when public APIs, wire contracts,
SwiftData schema, app lifecycle wiring, or visible UI behavior are affected.

- For shared-library logic, model, or test changes, run the `IncomesLibrary`
  scheme's tests on a discovered iOS Simulator destination.
- For public `IncomesLibrary` APIs, `*Operations`, shared sync contracts,
  SwiftData schema, or adapter-facing contracts, also build the `Incomes`
  scheme on a discovered iOS Simulator destination.
- For app compile checks, build the `Incomes` scheme on an iOS Simulator.
- For Widgets target changes, build the `Widgets` scheme on an iOS Simulator.
- For Watch target changes, build the `Watch` scheme on a watchOS Simulator.
  For Watch product linkage changes, also build `Incomes` to check embedding.
  Paired-device delivery remains separate runtime evidence.
- For runtime or UI-sensitive changes, add a targeted run, runtime-log review,
  Preview rendering when appropriate, and live UI or screenshot evidence.
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
architecture checks that are not covered by the Xcode-native integration.
SwiftLint is resolved from the `SimplyDanny/SwiftLintPlugins` package declared
in `Incomes.xcodeproj`, not from a separately installed `swiftlint` binary.
Xcode Cloud owns formal CI builds, tests, and archives.

Helper scripts may write disposable cache data under `.build/ci/shared/`.

## Release UI Smoke Audit

Release UI smoke auditing is separate from the standard verification entrypoint.
Keep it non-destructive by default: do not erase simulator data, reset
containers, or add UI test targets solely for the audit unless explicitly
requested.
