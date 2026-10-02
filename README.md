# Incomes

## Overview

Incomes is a budget planner for looking ahead at future balances and deciding
how to use your money. Planned income and expenses form the basis of that
outlook; recurring items, balance charts, and month/year views help users keep
their plan current across iPhone, Apple Watch, and widgets.

The app uses SwiftUI and stores data with SwiftData in a shared app
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

- **SwiftData + App Group** – the host app owns writes and migration in the
  store rooted at `group.com.muhiro12.Incomes`; widgets open it read-only.
  Watch uses an isolated in-memory store populated by phone snapshots. Update
  `AppGroup.id` when using your own bundle identifiers.
- **Database migration** – `DatabaseMigrator` moves legacy SQLite files into the
  shared container on first launch so long-time users keep their history.
- **WatchConnectivity bridge** – `PhoneWatchBridge` answers watch requests with
  typed `WatchSyncReply` payloads, while `PhoneSyncClient` manages activation
  and message replies on watchOS.
- **Preview infrastructure** – `IncomesSampleData` provisions an in-memory
  store, a named sample-data profile, and mock services so SwiftUI previews
  remain functional. See
  [Sample Data Profiles](Designs/Architecture/sample-data-profiles.md).

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
  [ARCHITECTURE_GUIDE.md](Designs/Architecture/ARCHITECTURE_GUIDE.md#live-app-data-flow),
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
  `1.14.0..<2.0.0`.

## Requirements

- Xcode 27 RC (27A266a), followed by the corresponding stable Xcode 27 release,
  for both development and release builds of Incomes 6.x.
- The app and widgets deploy to iOS 18 or later, and the watchOS companion
  deploys to watchOS 11 or later.
- An Apple Developer account configured for App Groups, iCloud, StoreKit 2,
  notifications, and ads.
- A device or simulator running iOS 26 or later with Foundation Models support
  for on-device inference features.

## Setup

Follow these steps to run a local build:

1. Clone the repository, check out `main` for Incomes 6.x, and open the project
   directory. The `5.12` tag preserves the released 5.x baseline.
2. Update bundle identifiers and the app group constant to match your
   provisioning profile if you are not using the production identifiers.
3. If you are shipping a fork with your own identifiers, update
   `IncomesLibrary/Sources/Persistence/AppGroup.swift`,
   `Incomes/Configurations/Incomes.entitlements`,
   `Watch/Configurations/Watch.entitlements`,
   `Widgets/Configurations/Widgets.entitlements`, and
   `Incomes/Sources/Platform/IncomesMonetizationConfiguration.swift`.
4. Open `Incomes.xcodeproj` in Xcode, select the **Incomes** scheme, and run on
   an iOS 18 or later simulator or device. Use an iOS 26 or later destination
   when testing Foundation Models features. Enable the **Watch** and
   **Widgets** schemes if you want to test the companion experiences.

### Remote configuration

The app downloads `.config.json` from the `main` branch on GitHub at launch.
Update the file or host your own endpoint when shipping a fork so update prompts
reflect your release channel.

## Build and Test

Use Xcode and the active Xcode-native integration for Apple build, test, run,
Simulator, runtime logs, Preview rendering, screenshots, and live UI inspection.
Xcode Cloud owns formal CI builds, tests, and archives.

Before changing Xcode selection, record the original scheme and destination,
switch only to discovered values, and end sessions or runs started solely for
verification. Restore the original scheme first, rediscover its destinations,
restore the original destination, and confirm the selection. Report failed
restoration.

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
  by the Xcode-native integration.
- Release UI smoke auditing uses live Simulator evidence. Use the
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

Choose verification by the changed boundary and resolve actions from the
active integration's tool inventory:

- Shared-library logic, model, or test changes: run the `IncomesLibrary`
  scheme's tests on a discovered iOS Simulator.
- Public library APIs, `*Operations`, shared sync or wire contracts, SwiftData
  schema, or adapter-facing contracts: also build the `Incomes` consumer scheme.
- App compile checks: build `Incomes` on a discovered iOS Simulator.
- Widgets changes: build `Widgets` on a discovered iOS Simulator.
- Watch changes: build `Watch` on a discovered watchOS Simulator. Product
  linkage changes also need an `Incomes` embedding build; paired-device
  delivery remains separate runtime evidence.
- Runtime or UI-sensitive changes: add a targeted run and runtime-log review,
  with Preview, live UI, or screenshot evidence appropriate to the change.

Runtime and UI checks require signed App Group entitlements at launch. Do not
disable signing for these checks; `CODE_SIGNING_ALLOWED=NO` is limited to
compile-only builds. Library tests, surface builds, and runtime/UI evidence
prove different boundaries.

Follow the repository SwiftLint configuration and existing Swift source style.
Markdown follows the [markdownlint rules](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md).

Helper scripts may write disposable cache data under `.build/ci/shared/`.

## Release operations

Incomes 6.x uses [Apogee release tools](Tools/Release/README.md) in a separate
macOS SwiftPM package. The package pins Apogee independently of the app and
supports local metadata validation, read-only release status, metadata, and
TestFlight feedback inspection, and reviewed version, metadata, screenshot,
build-attachment, and submission operations.

Xcode Cloud continues to own formal builds, tests, archives, and binary upload.
The workflow targets `main` with **Latest Beta or Release**. Check the actual
Xcode version in each candidate's build record and match it for local release
verification. Apogee creates App Store versions and changes publication policy
only through explicit, reviewed operations, and never builds or uploads
binaries.

## Useful links

- [App Store](https://apps.apple.com/app/id1584472982)
- [Privacy Policy](.github/pages/privacy.md)
