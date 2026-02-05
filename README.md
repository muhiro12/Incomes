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

- Capture receipts through the photo library or camera, or dictate statements
  with Speech Recognition, then run on-device VisionKit OCR to assemble a
  transcript.
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
  filtered payloads, while `PhoneSyncClient` manages activation and message
  replies on watchOS.
- **Preview infrastructure** – `IncomesPreview` provisions an in-memory store,
  sample data, and mock services so SwiftUI previews remain functional.

## Requirements

- Xcode 16 or later with the iOS 18 and watchOS 11 SDKs installed.
- An Apple Developer account configured for App Groups, iCloud, StoreKit 2,
  notifications, and ads.
- A device or simulator that supports Foundation Models for on-device inference
  features.

## Setup

Follow these steps to run a local build:

1. Clone the repository and open the project directory.
2. Update bundle identifiers and the app group constant to match your
   provisioning profile if you are not using the production identifiers.
3. Create `Incomes/Configurations/Secret.swift` and copy it to
   `Watch/Configurations/Secret.swift` with your StoreKit product ID and AdMob
   unit IDs:

   ```swift
   enum Secret {
       static let groupID = "group.com.example.incomes"
       static let productID = "com.example.incomes.premium"
       static let admobNativeID = "ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy"
       static let admobNativeIDDev = "ca-app-pub-3940256099942544/3986624511"
   }
   ```

4. Open `Incomes.xcodeproj` in Xcode, select the **Incomes** scheme, and run on
   an iOS 18 simulator or device. Enable the **IncomesWatch** and **Widgets**
   schemes if you want to test the companion experiences.

### Remote configuration

The app downloads `.config.json` from the `main` branch on GitHub at launch.
Update the file or host your own endpoint when shipping a fork so update prompts
reflect your release channel.

## Build and Test

Use the helper scripts in `ci_scripts/` as needed. If you are unsure, run the
required builds/tests based on local changes:

```sh
bash ci_scripts/run_required_builds.sh
```

If you only need the app build:

```sh
bash ci_scripts/build_incomes.sh
```

If you only need library tests:

```sh
bash ci_scripts/test_incomes_library.sh
```

## Useful links

- [App Store](https://apps.apple.com/app/id1584472982)
- [Privacy Policy](.github/pages/privacy.md)
