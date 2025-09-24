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

### Preferred: use `ci_scripts/` helpers

These scripts standardize invocation and keep artifacts under `build/` to avoid permission issues.

- List schemes:

  ```sh
  bash ci_scripts/xcodebuild_list_schemes.sh
  ```

- Run app tests (Incomes scheme):

  ```sh
  DERIVED_DATA_PATH=build/DerivedData \
  RESULTS_DIR=build \
  bash ci_scripts/xcodebuild_test_scheme.sh Incomes
  ```

- Run library tests (IncomesLibrary scheme):

  ```sh
  # Note: IncomesLibrary is iOS-only. Do not use `swift test`. `xcodebuild` is required because the scheme depends on the iOS Simulator runtime that `swift test` cannot drive.
  DERIVED_DATA_PATH=build/DerivedData \
  RESULTS_DIR=build \
  bash ci_scripts/xcodebuild_test_scheme.sh IncomesLibrary
  ```

- Options:
  - Prefer a specific simulator: set `UDID=<simulator-udid>`
  - Concise logs when available: pass `xcpretty` as the second arg

    ```sh
    bash ci_scripts/xcodebuild_test_scheme.sh Incomes xcpretty
    ```
  - Auto-fallback: If a scheme has no Test action, the script automatically falls back to `build`.
  - Force action: explicitly set `ACTION=test` or `ACTION=build` to override.
  - Artifacts:
    - Derived data: `build/DerivedData`
    - Results bundle: `build/TestResults_<Scheme>_<timestamp>.xcresult`

- Prerequisites:
  - Xcode with iOS Simulator runtime installed
  - At least one iPhone simulator available (booted is best)

- Equivalent raw commands (if you prefer `xcodebuild` directly):

- Run app tests (auto-pick latest iOS Simulator):

  ```sh
  xcodebuild -project Incomes.xcodeproj -scheme Incomes \
    -destination 'platform=iOS Simulator,OS=latest' test
  ```

- Run library tests (via Xcode scheme on iOS Simulator):

  ```sh
  # Note: IncomesLibrary is iOS-only. Do not use `swift test`. `xcodebuild` is required because the scheme depends on the iOS Simulator runtime that `swift test` cannot drive.
  xcodebuild -project Incomes.xcodeproj -scheme IncomesLibrary \
    -destination 'platform=iOS Simulator,OS=latest' test
  ```

- If destination resolution fails, target a specific simulator UDID:

  ```sh
  # Prefer a booted simulator
  UDID=$(xcrun simctl list devices | awk '/Booted/ {print $4; exit}' | tr -d '()')
  if [ -z "$UDID" ]; then
    # Else pick any iPhone simulator (Booted or Shutdown)
    UDID=$(xcrun simctl list devices | awk '/iPhone/ && /(Shutdown|Booted)/ {print $4; exit}' | tr -d '()')
  fi
  xcodebuild -project Incomes.xcodeproj -scheme Incomes -destination "id=$UDID" test
  xcodebuild -project Incomes.xcodeproj -scheme IncomesLibrary -destination "id=$UDID" test
  ```

- Tips:
  - Use `-resultBundlePath build/TestResults.xcresult` to save results. If it already exists, delete it or use a new path.
  - When piping output, add `set -o pipefail` to propagate failures.
  - If you need concise logs, install `xcpretty` and pipe `xcodebuild` output to it (optional).
