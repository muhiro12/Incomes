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

Agents MUST use the standardized CI helper:

``` sh
bash ci_scripts/run_required_builds.sh
```
