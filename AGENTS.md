# AGENTS.md

This document outlines the expectations and tooling references for contributors working on the Incomes project.

## Coding Guidelines for Codex Agents

This document defines the minimum coding standards for implementing Agents in the Codex project.

## Swift Code Guidelines

### Follow SwiftLint rules

All Swift code must comply with the SwiftLint rules defined in the project.

### Avoid abbreviated variable names

Do not use unclear abbreviations such as `res`, `img`, or `btn`.
Use descriptive and explicit names like `result`, `image`, or `button`.

### Use `.init(...)` when the return type is explicitly known

In contexts where the return type is clear (e.g., function return values, computed properties), use `.init(...)` for initialization.

#### Examples

##### Preferred

```swift
var user: User {
    .init(name: "Alice") // ✅ Return context explicitly typed as User
}
```

##### Not preferred

```swift
let user = .init(name: "Carol") // ❌ Local variable lacks an explicit type declaration
```

### Multiline control-flow and trailing-closure formatting

Avoid single-line bodies for **any** control-flow statement (`if`, `guard`, `while`, `switch`, etc.) or trailing closures.
Always place the body on its own indented line between braces to improve readability and make diffs cleaner.

#### Preferred

```swift
guard let currentUser = optionalUser else {
    return
}

if isDebugMode {
    logger.debug("Entering debug state")
}

tasks.filter {
    $0.isCompleted
}
```

#### Not preferred

```swift
guard let currentUser = optionalUser else { return }
if isDebugMode { logger.debug("Entering debug state") }
tasks.filter { $0.isCompleted }
```

## Markdown Guidelines

### Follow markdownlint rules for Markdown files

All Markdown documents must conform to the rules defined at:
https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md

## Project-wide Conventions

### Use English for naming and comments

Use English for:

- Branch names (e.g., `feature/add-intent-support`, `bugfix/crash-on-startup`)
- Code comments
- Documentation and identifiers (variables, methods, etc.)

Avoid using Japanese or other non-English languages in code unless strictly necessary (e.g., legal compliance, UI text localization).

## Test Commands

Use these minimal, reliable commands to build and run tests via Xcode. They avoid hard-coding device names and work across environments.

### Preferred: use `ci_scripts/` helper

This script standardizes invocation, keeps artifacts under `build/`, and does not accept arguments.

- Run required build/tests based on local changes:

  ```sh
  bash ci_scripts/run_required_builds.sh
  ```

- Artifacts:
  - Derived data: `build/DerivedData`
  - Results bundle: `build/TestResults_<Scheme>_<timestamp>.xcresult`
