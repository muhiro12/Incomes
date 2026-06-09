# Incomes

**A modern budget manager built with SwiftUI, SwiftData and the latest Apple frameworks.**

[![Download on the App Store](https://linkmaker.itunes.apple.com/assets/shared/badges/en-us/appstore-lrg.svg)](https://apps.apple.com/app/id1584472982)

## Highlights

- 📸 **Intelligent capture** – scan receipts with VisionKit, dictate with
  SpeechKit or import photos, then let Foundation Models infer the form for you.
- 🧮 **Powerful logging** – handle recurring items, tags and balance
  calculations with one tap.
- 📈 **Search & insights** – drill into months and categories with Swift Charts
  and rich filters.
- 🔔 **Stay ahead** – fine-tune push reminders, lead times and thresholds for
  upcoming payments.
- 🌐 **Premium sync** – unlock iCloud syncing, ad removal and StoreKit-managed
  subscriptions.

## Platforms

- **iPhone & iPad** – full budgeting experience with charts, Siri Shortcuts and
  App Intents.
- **Apple Watch** – glanceable upcoming payments plus subscription management
  on the wrist.
- **Widgets & Live Activities** – balance, upcoming and control widgets keep
  finances visible in StandBy and on the Home Screen.

## Build from source

1. Clone the repository.
2. If you are using your own identifiers, update
   `IncomesLibrary/Sources/Common/AppGroup.swift`, the entitlements files under
   `Incomes/Configurations`, `Watch/Configurations`, and
   `Widgets/Configurations`, plus
   `Incomes/Sources/Common/Platform/IncomesMonetizationConfiguration.swift`.
3. Open `Incomes.xcodeproj` in Xcode 26 or later and run the **Incomes** scheme
   on an iOS 18 or later simulator or device. Use an iOS 26 or later
   destination when testing Foundation Models features.

See the [README](https://github.com/muhiro12/Incomes#readme) for detailed setup
instructions, testing commands and remote configuration notes.

## Links

- [App Store](https://apps.apple.com/app/id1584472982)
- [Privacy Policy](privacy.html)
