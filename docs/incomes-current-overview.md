# Incomes Current Product and Architecture Overview

Current as of March 4, 2026.

## Purpose

Incomes is a SwiftUI household finance app centered on scheduled income and
outgo tracking. The product is implemented as one shared domain library plus
multiple surfaces:

- An iPhone app for full data entry, browsing, analytics, settings, and
  maintenance
- An Apple Watch companion focused on recent and upcoming items
- WidgetKit widgets for month summaries, net income, and upcoming items
- App Intents and Shortcuts entry points for automation and Siri

The current implementation is intentionally biased toward a single source of
truth for business logic in `IncomesLibrary`, with platform adapters and UI
living in the app targets.

## Product Surface Summary

| Surface | Current role | Key responsibilities |
| --- | --- | --- |
| `Incomes` | Primary product surface | Data entry, browsing, charts, search, notifications, subscription, sync settings, ads, deep links, App Intents, debug tools |
| `Watch` | Lightweight companion | Show upcoming items, reload recent months from phone, inspect items in debug mode |
| `Widgets` | Passive glanceable surface | Show month totals, month net income, next or previous item, deep-link back into the app |
| `IncomesLibrary` | Shared domain layer | SwiftData models, predicates, calculators, yearly duplication, notification planning, maintenance services, routes |

## Current End-User Features

### 1. Item capture and creation

- Create an item with date, content, income, outgo, category, and priority.
- Create from a selected year, month, content tag, or category tag, which
  pre-fills the form contextually.
- Duplicate an existing item into a new create flow.
- Create repeating items in two ways:
  - A simple repeat count via App Intents.
  - An explicit month picker in the iPhone UI, covering the base year and the
    following year.
- Keep the base month always included in repeating schedules.
- Show live suggestion chips for content and category based on existing tags.
- Validate that content is non-empty and numeric fields are decimal-safe before
  saving.

### 2. Assisted input and on-device inference

- On iOS 26 and later, open an assist sheet from the item form.
- Paste raw text manually into the assist sheet.
- Import an image from the photo library.
- Capture a new image with the camera.
- Run on-device VisionKit text recognition on imported images.
- Run Apple Foundation Models inference to extract:
  - date
  - content
  - income
  - outgo
  - category
- Apply the inferred values back into the item form.
- Expose the same inference capability through a hidden App Intent.

### 3. Item editing and mutation

- Open item details from list rows and context menus.
- Edit a single item.
- When the item belongs to a repeat series, choose mutation scope:
  - this item only
  - future items in the same series
  - all items in the same series
- Delete a single item or a list selection.
- Recalculate balances from a given item onward.

### 4. Year, month, content, and category browsing

- Show years in the main sidebar.
- Show year summary rows with:
  - item count
  - total income
  - total outgo
  - a deficit warning when any related item balance is negative
- Show months inside the selected year.
- Open a month detail screen with:
  - month item list
  - balance chart
  - income and outgo chart
  - category income and outgo breakdown
- Open a year detail screen with year-scoped charts.
- Open content-based history across years.
- Open category-based history across years.
- Delete all items belonging to a selected year or month from list swipe
  actions.

### 5. Analytics and summaries

- Calculate and persist running balance per item.
- Show a balance line and area chart.
- Show income and outgo bar charts.
- Show category donut charts separately for income and outgo.
- Show month totals in widgets through shared calculators.
- On iOS 26 and later, generate an on-device monthly narrative summary for the
  open month.
- Monthly narrative summaries use only local data and compare the current month
  with the previous month.
- Expose the monthly summary generator through a hidden App Intent.

### 6. Search and discovery

- Present an in-app search mode from the main split view.
- Search by content tag.
- Search by category tag.
- Search by balance range.
- Search by income range.
- Search by outgo range.
- Filter tag suggestions using normalized matching, including Japanese
  kana-friendly matching in the tag predicate layer.
- Show grouped search results by month.

### 7. Notifications and reminder scheduling

- Let users enable or disable upcoming payment notifications.
- Let users set a minimum outgo threshold.
- Let users choose how many days before the due date to notify.
- Let users choose the delivery time.
- Request notification permission when reminders are registered.
- Register upcoming payment reminders using shared planning logic.
- Send a test notification from Settings.
- Deep-link from a notification to either:
  - the specific item
  - the related month
- Maintain badge counts and remove delivered notifications during refresh.
- Show current authorization status in Settings and offer a shortcut to system
  settings when permission is denied.

### 8. Yearly duplication and bulk planning

- Offer a dedicated yearly duplication screen from Settings.
- Suggest likely source and target years based on available year tags and
  repeat-group density.
- Build a duplication plan that groups source items by repeat pattern or by
  content and category fallback.
- Skip entries that already exist in the target year when configured to do so.
- Preview:
  - group count
  - item count
  - skipped duplicate count
- Create one proposed group directly.
- Edit a proposed group before creation by opening the item form with a draft.
- Expose preview and apply flows through hidden App Intents.
- Surface a seasonal promo for yearly duplication during late-year and
  early-year months.

### 9. Tag maintenance

- Detect duplicate tags across year, month, content, and category types.
- Show duplicate groups in a dedicated maintenance flow.
- Inspect items attached to each duplicate tag variant.
- Merge duplicate tags by reattaching child tag items to a chosen parent.
- Resolve all duplicate tags of a given type from the list screen.
- Delete a selected duplicate tag manually.
- Expose duplicate-resolution through a hidden App Intent.

### 10. Settings, subscription, and monetization

- Show subscription entry points when premium is not active.
- Use StoreKit 2 subscription state to determine premium access.
- Gate iCloud sync behind the premium subscription state.
- Disable iCloud sync automatically when premium is not active.
- Allow currency code selection from all supported currency codes.
- Show open-source license information.
- Show app version and build number.
- Show reusable TipKit education flows again on demand.
- Show Google Mobile Ads native placements when premium is not active.

### 11. Remote configuration and update gating

- Fetch `.config.json` from the GitHub `main` branch at launch and on each
  foreground activation.
- Compare the required version with the installed app version.
- Present a blocking update-required alert when the remote minimum version is
  above the installed version.

### 12. Shortcuts, Siri, and App Intents

- Provide app shortcuts for:
  - opening the app
  - creating and showing an item
  - showing this month's items
  - showing this month's charts
  - showing the upcoming item
  - showing upcoming items
  - showing the most recent item
  - showing recent items
- Provide App Intents for item lifecycle operations:
  - create item
  - create scheduled item
  - update item
  - delete item
  - recalculate balances
- Provide App Intents for data retrieval:
  - all item count
  - month items
  - year item count
  - repeat item count
  - next and previous item variants
  - next and previous item content, date, and net income variants
- Provide App Intents for UI routing:
  - open app
  - open explicit in-app routes
  - show items and charts
  - show next, previous, upcoming, or recent item screens
- Treat non-user-facing operational intents as hidden adapters rather than
  public shortcut features.

### 13. Tips, prompts, and review nudges

- Use TipKit to guide key flows such as:
  - first item creation
  - repeat item creation
  - month browsing
  - item detail usage
  - search
  - subscription
  - yearly duplication
- Request App Store review opportunistically after create or save flows and on
  foreground activation using randomized policies.

### 14. Debug and internal maintenance features

- Enable or disable a debug option.
- Seed rich preview or tutorial-style sample data.
- Seed duplicate-prone sample data intentionally for duplicate tag testing.
- View all items and all tags from debug navigation.
- Reset or force-show TipKit state for testing.
- Inspect ads and subscription screens from debug mode.
- Remove debug sample data from iPhone and Apple Watch surfaces.
- Allow a hidden form gesture path where cancelling with the content text
  `Enable Debug` turns on debug mode.

## Apple Watch Features

- Store data in the same domain model format as the iPhone app.
- On launch, activate `WatchConnectivity` and request recent items from the
  phone.
- Sync a trimmed snapshot for the previous, current, and next month only.
- Replace local watch data for those months during sync.
- Show the upcoming day of items on the main watch screen.
- Show a manual reload action.
- Show a Settings entry point.
- In debug mode, inspect all items and tags and remove debug sample data.

## Widget Features

### Month summary widget

- Configurable for previous, current, or next month.
- Shows total income and total outgo for the selected month.
- Deep-links into the corresponding month in the app.

### Month net income widget

- Configurable for previous, current, or next month.
- Shows the net income for the selected month.
- Indicates positive or negative direction visually.
- Deep-links into the corresponding month in the app.

### Upcoming widget

- Configurable for next or previous item direction.
- Shows the date, content, and net amount of the selected item.
- Deep-links to the item when possible and falls back to the relevant month or
  home route.

## Data Model and Storage Design

### Core model

`Item` is the central financial record and currently stores:

- UTC-backed persisted date
- content
- income
- outgo
- priority
- repeat series identifier
- running balance
- derived relationships to tags

`Tag` is a derived grouping model used for navigation, filtering, and
aggregation. Current tag types are:

- `year`
- `yearMonth`
- `content`
- `category`
- `debug`

### Derived tagging strategy

Every created or modified item automatically reattaches four derived tags:

- year
- year-month
- content
- category

This is a deliberate denormalized indexing strategy. The app navigates by tags,
while the shared library still resolves many queries directly from item data to
avoid semantic drift when duplicates exist.

### Persistence and sharing

- The canonical SwiftData store lives in the shared app group container
  `group.com.muhiro12.Incomes`.
- Legacy SQLite files are migrated from the old Application Support location
  into the shared container on first launch.
- The iPhone app can build its model container with CloudKit enabled or
  disabled, based on the stored premium sync setting.
- Widgets and watch-related helpers read the same schema through shared
  container factories or snapshot payloads.

### Balance behavior

- Running balance is persisted on each item.
- Balance is recalculated from the earliest affected date after item creates,
  updates, deletes, sync replacements, and sample-data seeding.

## Current Architecture and Design Policies

### 1. Shared library is the source of truth

Accepted ADRs and the current codebase agree on one rule: reusable business
logic belongs in `IncomesLibrary`.

Current shared business entry points include:

- `ItemService`
- `TagService`
- `SummaryCalculator`
- `YearlyItemDuplicator`
- `UpcomingPaymentPlanner`
- `DataMaintenanceService`
- `SettingsStatusLoader`

### 2. App target owns platform adapters

Capabilities that require Apple or third-party platform frameworks stay in the
`Incomes` target. Current examples include:

- `NotificationService`
- `ItemInferenceService`
- StoreKit subscription handling
- Google Mobile Ads integration
- deep-link intake from URLs and notifications
- App Intent adapter types

The design intent is that adapters translate between platform APIs and shared
domain services instead of duplicating business rules.

### 3. Views own presentation, not business rules

SwiftUI views currently own:

- presentation state
- local focus and sheet state
- navigation decisions
- confirmation dialogs
- detail layout

They are not supposed to become the source of truth for mutations,
deduplication, yearly duplication rules, or calculations. Those rules are
delegated to coordinators or shared services.

### 4. App Intents are adapters

App Intents are designed as adapters over shared operations, not a second
business layer. They may:

- validate parameters
- resolve entities
- convert values into `ItemFormInput`
- call shared services
- open app routes

They should not own domain branching that also exists in the UI.

### 5. One shared module by default

The current architecture explicitly keeps reusable business logic in one module,
`IncomesLibrary`, unless there is a stronger reason than organization alone to
split it further.

### 6. Routing is explicit and shareable

The app defines canonical in-app routes such as:

- home
- settings and settings subpages
- year summary
- yearly duplication
- duplicate tags
- year
- month
- item
- search

Those routes can be:

- parsed from universal links or custom scheme URLs
- emitted by notifications
- opened from widgets
- triggered by App Intents

### 7. Preview and sample-data infrastructure is first-class

- SwiftUI previews use an in-memory model container.
- Shared sample data seeding produces realistic finance data for previews and
  debugging.
- The preview stack also injects notification, configuration, store, and ad
  services so the UI stays operable in isolation.

## Canonical Shared Behaviors

The following behaviors are already centralized and should remain centralized:

- item creation and repeat generation
- repeat-aware item updates
- item deletion and affected-balance recalculation
- duplicate tag detection and merge resolution
- month totals and category comparison calculations
- yearly duplication planning and application
- notification planning for upcoming payments
- whole-store deletion and debug-data deletion
- settings status loading for duplicate tags and debug data

## Notable Version and Capability Gates

- The baseline product targets iOS 18 and watchOS 11 era APIs.
- On-device text inference and monthly narrative summaries require iOS 26 and
  Apple Foundation Models availability.
- Notification features depend on user authorization.
- iCloud sync depends on premium entitlement state.
- Ads are shown only when premium is not active.

## Practical Reading of the Current Product

In its current form, Incomes is not just a simple expense logger. It is a
scheduled personal finance tracker with strong support for recurring entries,
derived navigation tags, multi-surface access, deep-linkable routes, local
analytics, and on-device AI-assisted input. The architecture is intentionally
set up so that finance rules are shared once, while platform-specific behavior
stays at the edges.
