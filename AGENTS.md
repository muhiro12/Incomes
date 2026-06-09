# AGENTS.md

This document defines the **repository-specific agent behavior contract** for
Incomes. It contains only strict, minimal rules that agents must follow when
working in this repository.

## Agent Philosophy

- Follow existing repository conventions as the source of truth.
- Do not invent architecture or workflows.
- When uncertain, prefer leaving TODO comments rather than guessing.
- Prefer **minimal, safe changes** over large refactors.

## Naming and Language Rules

Use English for:

- Branch names
- Code comments
- Documentation
- Identifiers

Avoid non-English text unless required for UI localization or legal content.

## Markdown Guidelines

All Markdown files must follow:

https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md

## Swift Code Guidelines

### Follow SwiftLint rules

All Swift code must comply with the project's SwiftLint configuration.

### Avoid abbreviated variable names

#### Preferred

- `result`
- `image`
- `button`

#### Not preferred

- `res`
- `img`
- `btn`

### Use `.init(...)` when return type is explicit

#### Preferred

``` swift
var user: User {
    .init(name: "Alice")
}
```

#### Not preferred

``` swift
var user: User {
    User(name: "Alice")
}
```

### Multiline control-flow formatting

Do NOT use single-line bodies for control-flow statements or trailing closures.

#### Preferred

```swift
guard let currentUser else {
    return
}

if isDebugMode {
    logger.debug("Entering debug state")
}

tasks.filter { task in
    task.isCompleted
}
```

#### Not preferred

```swift
guard let currentUser else { return }
if isDebugMode { logger.debug("Entering debug state") }
tasks.filter { $0.isCompleted }
```

## Build and Test Entry Point

Agents MUST prefer XcodeBuildMCP for Apple build, test, run, Simulator,
runtime log, screenshot, and UI snapshot verification.

For app compile checks, use XcodeBuildMCP `build_sim` with the `Incomes`
scheme. For shared-library tests, use XcodeBuildMCP `test_sim` with the
`IncomesLibrary` scheme. For runtime or UI-sensitive checks, use
XcodeBuildMCP `build_run_sim`, `launch_app_sim`, `snapshot_ui`, and
`screenshot` as appropriate.

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

Release UI smoke auditing is separate from the standard verification
entrypoint. When release or UI-sensitive work needs live Simulator evidence,
use the global `$xcode-ui-smoke-auditor` skill and keep the audit
non-destructive by default. Do not erase simulator data, reset containers, or
add UI test targets solely for the audit unless explicitly requested.
