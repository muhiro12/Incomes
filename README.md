# Incomes

Incomes is a Cupertino-style budget manager that keeps your finances organised across iPhone, Apple Watch and widgets.

[Download on the App Store](https://apps.apple.com/app/id1584472982)

## Features

### Intelligent capture

- Capture receipts or statements from the photo library, camera or microphone and let on-device speech recognition and Vision extract the text automatically.
- Use Foundation Models–powered inference to pre-fill the item form with dates, categories and amounts in the user’s locale.

### Fast logging and organisation

- Log incomes and outgoings with repeat counts, categories and contextual shortcuts straight from the form view.
- Automatically create future occurrences for recurring payments and keep balances accurate through the shared data layer.
- Resolve duplicate tags, recalculate balances and clean up tutorial data directly from Settings.

### Search and insights

- Search by content, category or numeric ranges with menu-driven filters to drill into any time period.
- Browse yearly summaries, detailed charts and profit breakdowns powered by Swift Charts and SwiftData predicates.

### Stay on schedule

- Configure rich push-notification rules, including thresholds, lead times, delivery windows and test notifications.
- Automatic upcoming-payment reminders keep badge counts and delivered notifications in sync across devices.

### Available everywhere

- A collection of widgets for balance snapshots, upcoming items, monthly breakdowns, control widgets and Live Activities keeps data on the Home Screen and StandBy.
- The watchOS companion lists upcoming payments, manages subscriptions and mirrors notification settings right from the wrist.

### Premium and sync options

- Subscribers unlock iCloud syncing, remove ads and manage their plan through StoreKit 2 and the in-app paywall.
- Non-subscribers see Google Mobile Ads placements that are shared across the app and widgets.
- A remote configuration feed allows urgent update requirements to be enforced without shipping a new build.

## Targets and shared modules

- **Incomes** – the main iOS app built with SwiftUI and SwiftData, including CloudKit-backed syncing when iCloud is enabled.
- **Watch** – a watchOS companion that uses the same SwiftData store and StoreKit subscription logic.
- **Widgets** – WidgetKit bundle providing multiple Home Screen widgets, Live Activities and control widgets.
- **IncomesLibrary** – a reusable module containing the data model, business logic, migration utilities and notification planners shared across all targets.

External packages such as StoreKitWrapper, GoogleMobileAdsWrapper, PhotosUI, SpeechWrapper and VisionKit are used to integrate subscriptions, advertising and media capture.

## Getting started

### Requirements

- Xcode 16 (iOS 18 / watchOS 11 SDKs) or later
- An Apple Developer account for configuring App Group, iCloud and StoreKit entitlements

### Project setup

1. Clone the repository.
2. Create `Incomes/Configurations/Secret.swift` (and copy it to `Watch/Configurations/Secret.swift`) containing your identifiers:

   ```swift
   enum Secret {
       static let groupID = "group.com.example.incomes"
       static let productID = "com.example.incomes.premium"
       static let admobNativeID = "ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy"
       static let admobNativeIDDev = "ca-app-pub-3940256099942544/3986624511" // Google test ID
   }
   ```

   Xcode Cloud retrieves the same file from the `SECRET_BASE64` environment variable during CI builds.
3. Open `Incomes.xcodeproj` in Xcode and select the **Incomes** scheme.
4. Run on an iOS 18 simulator or device. Enable the **IncomesWatch** and **Widgets** schemes if you want to test companion experiences.

### Remote configuration

The app downloads `.config.json` from the `main` branch on GitHub at launch to learn about required versions or feature flags. Host your own file if you fork the project.

### Testing

Run the shared test suites from macOS using Xcode command line tools:

```sh
xcodebuild -project Incomes.xcodeproj -scheme Incomes \
  -destination 'platform=iOS Simulator,OS=latest' test

xcodebuild -project Incomes.xcodeproj -scheme IncomesLibrary \
  -destination 'platform=iOS Simulator,OS=latest' test
```

## Links

- [App Store](https://apps.apple.com/app/id1584472982)
- [Privacy Policy](.github/pages/privacy.md)

