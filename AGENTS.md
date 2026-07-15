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

Agents MUST prefer the Xcode-native integration available in the current agent
environment for project discovery, active scheme and destination selection,
build, test, run, runtime logs, Preview rendering, live UI inspection, and
screenshots.

Before changing Xcode's active selection, discover the open projects, schemes,
and run destinations, identify `Incomes.xcodeproj`, and record the original
active scheme and destination. Switch only to scheme and destination values
returned by discovery. After verification, restore the original scheme first,
rediscover its valid destinations, restore the original destination, and
confirm the final selection. Report any selection that cannot be restored.

Treat library tests, surface builds, and runtime/UI evidence as separate
verification capabilities. Choose the smallest set that proves the current
change, and prefer stronger evidence when public APIs, wire contracts,
SwiftData schema, app lifecycle wiring, or visible UI behavior are affected.

- For shared-library logic, model, or test changes, use the available
  Xcode-native test capability with project `Incomes.xcodeproj`, scheme
  `IncomesLibrary`, and a discovered iOS Simulator destination.
- For public `IncomesLibrary` APIs, `*Operations`, shared sync contracts,
  SwiftData schema, or adapter-facing contracts, also build
  `Incomes.xcodeproj` with the `Incomes` scheme through the available
  Xcode-native integration.
- For app compile checks, use the Xcode-native build capability with project
  `Incomes.xcodeproj`, scheme `Incomes`, and a discovered iOS Simulator
  destination.
- For Watch or Widgets target changes, use the same build capability with the
  `Watch` or `Widgets` scheme and a compatible discovered destination.
- For runtime or UI-sensitive changes, add a targeted Xcode-native run,
  runtime-log review, Preview rendering when appropriate, and live UI or
  screenshot evidence.
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
architecture checks that are not naturally covered by the available
Xcode-native integration.
SwiftLint is resolved from the `SimplyDanny/SwiftLintPlugins` package declared
in `Incomes.xcodeproj`, not from a separately installed `swiftlint` binary.
Xcode Cloud owns formal CI builds, tests, and archives.

Helper scripts may write disposable cache data under `.build/ci/shared/`.

## Release UI Smoke Audit

Release UI smoke auditing is separate from the standard verification entrypoint.
Keep it non-destructive by default: do not erase simulator data, reset
containers, or add UI test targets solely for the audit unless explicitly
requested.
