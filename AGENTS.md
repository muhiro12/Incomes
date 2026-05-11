# AGENTS.md

This document defines the **global agent behavior contract** shared across projects.  
It contains only strict, minimal rules that agents must always follow.

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

Agents MUST use this standardized verification entrypoint:

``` sh
bash ci_scripts/tasks/verify_task_completion.sh
```

Agents may run `bash ci_scripts/tasks/check_environment.sh --profile verify`
first to diagnose missing local prerequisites.
When Swift files are edited, agents should run
`bash ci_scripts/tasks/format_swift.sh` before the final verification gate.
`bash ci_scripts/tasks/verify_task_completion.sh` is the non-destructive
verification gate.
`bash ci_scripts/tasks/verify_pre_push.sh` is the optional Git `pre-push`
wrapper for the same non-destructive verification gate.
`bash ci_scripts/tasks/verify_repository_state.sh` is the supplemental
repository-state verification entrypoint that still writes CI run artifacts.
SwiftLint is resolved from the `SimplyDanny/SwiftLintPlugins` package declared
in `Incomes.xcodeproj`, not from a separately installed `swiftlint` binary.

CI run artifacts are written under `.build/ci/runs/<RUN_ID>/`.
Each run stores `summary.md`, `commands.txt`, `meta.json`, `logs/`, `results/`, and `work/`.
Shared CI directories are under `.build/ci/shared/` (`cache/`, `DerivedData/`, `tmp/`, `home/`).
Only the newest 5 run directories are retained.
The entire `.build/ci` directory is disposable.

## Release UI Smoke Audit

Release UI smoke auditing is separate from the standard verification
entrypoint. When release or UI-sensitive work needs live Simulator evidence,
use the global `$xcode-ui-smoke-auditor` skill and keep the audit
non-destructive by default. Do not erase simulator data, reset containers, or
add UI test targets solely for the audit unless explicitly requested.
