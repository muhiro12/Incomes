# Incomes

## Overview

Incomes is a SwiftUI budgeting app that keeps personal finances organised across
iPhone, Apple Watch, and widgets. It stores data with SwiftData in a shared app
group container, optionally syncs through CloudKit, and layers on StoreKit 2
subscriptions, Google Mobile Ads, and App Intents powered by Apple Foundation
Models.

[Download on the App Store](https://apps.apple.com/app/id1584472982)

## Targets

- **Incomes** – the iOS app that drives the end-to-end experience with SwiftUI
  views, SwiftData, and on-device services such as notifications, ads, and App
  Intents.
- **Watch** – a watchOS companion that mirrors upcoming payments, settings, and
  debug utilities while staying in sync with the phone via WatchConnectivity
  snapshots.
- **Widgets** – a WidgetKit bundle that surfaces balances, upcoming
  transactions, and monthly breakdowns on the Home Screen and StandBy.
- **IncomesLibrary** – the shared domain layer containing the SwiftData models,
  balance calculator, notification planner, and sync payloads used by every
  target.

## Feature highlights

### Capture and inference

- Capture receipts through the photo library or camera, then run on-device
  VisionKit text recognition to assemble a transcript.
- Use Apple Foundation Models to infer the date, amounts, and category that
  pre-populate the item form or App Intent output, respecting the user’s
  locale.

### Logging and organisation

- Create and edit items with repeat tracking, categorisation, and automatic tag
  management to keep yearly and monthly views tidy.
- Seed preview or debug databases with realistic sample data to explore the UI
  without real transactions.

### Insights and search

- Drill into periods or categories using search targets and tag summaries backed
  by SwiftData queries and chart-ready aggregates.

### Notifications and schedules

- Configure notification rules, register reminders, and deliver badge-aware
  updates with the notification service and planner.
- Trigger test alerts and refresh badge counts to keep multiple devices in
  sync.

### Cross-device experiences

- Share data through a single SwiftData store located in the app group
  container, with legacy SQLite migration for existing users.
- Sync recent transactions to watchOS by replying to WatchConnectivity requests
  with trimmed JSON payloads and recalculating balances after import.

### Premium, sync, and remote configuration

- Open the StoreKit 2 paywall to manage premium subscriptions, automatically
  toggle iCloud sync, and start Google Mobile Ads placements.
- Fetch `.config.json` from GitHub at launch to learn about required versions or
  feature flags, and prompt users to update when needed.

### App Intents and shortcuts

- Offer App Intents for quickly opening the app or requesting Foundation Model
  inference from Shortcuts and Siri.

## Architecture and technologies

- **SwiftData + App Group** – all targets read and write through a shared model
  container rooted at `group.com.muhiro12.Incomes`; update `AppGroup.id` when
  using your own bundle identifiers.
- **Database migration** – `DatabaseMigrator` moves legacy SQLite files into the
  shared container on first launch so long-time users keep their history.
- **WatchConnectivity bridge** – `PhoneWatchBridge` answers watch requests with
  typed `WatchSyncReply` payloads, while `PhoneSyncClient` manages activation
  and message replies on watchOS.
- **Preview infrastructure** – `IncomesPreview` provisions an in-memory store,
  sample data, and mock services so SwiftUI previews remain functional.

## Architecture records

- `IncomesLibrary` is the app's behavioral source of truth. It owns the product
  rules that should remain correct regardless of whether the user reaches them
  through iOS, iPadOS, watchOS, widgets, App Intents, or Shortcuts.
- Thin targets in this repository are responsibility-thin, not line-count-thin.
  `Incomes`, `Watch`, `Widgets`, and App Intents may still own SwiftUI shells,
  lifecycle wiring, routing, and framework adapters, but reusable finance rules
  and shared sync contracts belong in `IncomesLibrary`.
- `IncomesLibrary` owns the shared SwiftData model, mutation/query services,
  widget snapshot builders, and cross-target sync types such as
  `WatchSyncReply`.
- `Incomes`, `Watch`, `Widgets`, and App Intents consume those shared APIs and
  remain the place for Apple-specific integration work such as notifications,
  WatchConnectivity, WidgetKit, StoreKit, ads, and Foundation Models.
- When `IncomesLibrary` is correctly tested, destructive product-behavior
  regressions should be caught there; target-local failures should usually be
  limited to presentation, routing, dependency wiring, or platform delivery.
- Automated unit tests stay in `IncomesLibrary/Tests`. This repository does not
  add separate unit test targets for `Incomes`, `Watch`, or `Widgets`; those
  adapters are verified through builds plus shared-library tests.
- Start detailed architecture reading from
  [ARCHITECTURE_GUIDE.md](Designs/Architecture/ARCHITECTURE_GUIDE.md),
  [shared-service-design.md](Designs/Architecture/shared-service-design.md),
  [incomes-current-overview.md](Designs/Overviews/incomes-current-overview.md),
  and
  [incomes-architecture-conformance-audit.md](Designs/Overviews/incomes-architecture-conformance-audit.md).

## Platform package posture

- `Incomes` intentionally adopts the full `MHPlatform` umbrella because the app
  uses package-owned runtime surfaces plus route, mutation, and review shells.
- `IncomesLibrary` intentionally adopts `MHPlatformCore` as the shared-library
  umbrella for core-safe platform helpers.
- `Watch` intentionally stays on the narrower `MHPreferences` product.
- `Widgets` intentionally stay off direct MHPlatform package adoption.
- This repository intentionally tracks MHPlatform with the 1.x semver range
  `1.0.0..<2.0.0`.

## Requirements

- Xcode 26 or later.
- The app and widgets deploy to iOS 18 or later, and the watchOS companion
  deploys to watchOS 11 or later.
- An Apple Developer account configured for App Groups, iCloud, StoreKit 2,
  notifications, and ads.
- A device or simulator running iOS 26 or later with Foundation Models support
  for on-device inference features.

## Setup

Follow these steps to run a local build:

1. Clone the repository and open the project directory.
2. Update bundle identifiers and the app group constant to match your
   provisioning profile if you are not using the production identifiers.
3. If you are shipping a fork with your own identifiers, update
   `IncomesLibrary/Sources/Common/AppGroup.swift`,
   `Incomes/Configurations/Incomes.entitlements`,
   `Watch/Configurations/Watch.entitlements`,
   `Widgets/Configurations/Widgets.entitlements`, and
   `Incomes/Sources/Common/Platform/IncomesMonetizationConfiguration.swift`.
4. Open `Incomes.xcodeproj` in Xcode, select the **Incomes** scheme, and run on
   an iOS 18 or later simulator or device. Use an iOS 26 or later destination
   when testing Foundation Models features. Enable the **Watch** and
   **Widgets** schemes if you want to test the companion experiences.

### Remote configuration

The app downloads `.config.json` from the `main` branch on GitHub at launch.
Update the file or host your own endpoint when shipping a fork so update prompts
reflect your release channel.

## Build and Test

Use Xcode and XcodeBuildMCP for Apple build, test, run, Simulator, runtime log,
screenshot, and UI snapshot verification. Xcode Cloud owns formal CI builds,
tests, and archives.

The remaining helper scripts in `ci_scripts/` are intentionally small. Direct
entrypoints live in `ci_scripts/tasks/`, shared shell helpers live in
`ci_scripts/lib/`, and `ci_scripts/ci_post_clone.sh` is reserved for external
post-clone CI setup.

- `bash ci_scripts/tasks/check_environment.sh --profile <swiftlint|rules>`
  diagnoses missing local prerequisites before running the retained scripts.
- `bash ci_scripts/tasks/format_swift.sh` is the explicit SwiftLint autofix
  step to run after Swift edits.
- `bash ci_scripts/tasks/lint_swift.sh` runs the project-managed SwiftLint
  binary without requiring a separately installed `swiftlint` command.
- `bash ci_scripts/tasks/check_repository_rules.sh` runs SwiftLint plus the
  repository-specific static architecture checks that are not naturally covered
  by XcodeBuildMCP.
- Release UI smoke auditing uses XcodeBuildMCP live Simulator evidence. Use the
  [release UI smoke audit guide](Designs/Architecture/release-ui-smoke-audit.md)
  when a release or UI-sensitive change needs live Simulator evidence.

SwiftLint is resolved from the `SimplyDanny/SwiftLintPlugins` package declared
in `Incomes.xcodeproj`. The repository scripts do not require a separately
installed `swiftlint` binary on your `PATH`.

Before running retained script checks, diagnose the local prerequisites:

```sh
bash ci_scripts/tasks/check_environment.sh --profile rules
```

After Swift edits, run the explicit autofix step:

```sh
bash ci_scripts/tasks/format_swift.sh
```

Then run the retained repository rule checks:

```sh
bash ci_scripts/tasks/check_repository_rules.sh
```

If you prefer to run the SwiftLint steps directly:

```sh
bash ci_scripts/tasks/format_swift.sh
bash ci_scripts/tasks/lint_swift.sh
```

For app build checks, use XcodeBuildMCP `build_sim` with the `Incomes` scheme.
For shared-library tests, use XcodeBuildMCP `test_sim` with the
`IncomesLibrary` scheme. For runtime or UI-sensitive checks, use XcodeBuildMCP
`build_run_sim`, `launch_app_sim`, `snapshot_ui`, and `screenshot`.
Treat these as separate verification capabilities: library tests prove shared
business behavior, surface builds prove adapter integration, and runtime or UI
evidence is reserved for changes that affect visible behavior or live platform
integration.

Helper scripts may write disposable cache data under `.build/ci/shared/`.

## Useful links

- [App Store](https://apps.apple.com/app/id1584472982)
- [Privacy Policy](.github/pages/privacy.md)
