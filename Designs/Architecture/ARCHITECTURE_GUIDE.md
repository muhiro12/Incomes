# Incomes Architecture Guide

## Scope

This guide defines the strict `domain-in-library, UI-as-adapter` policy for this repository.

Related document:
[shared-service-design.md](./shared-service-design.md)

## Responsibility Boundaries

| Layer | Owns | Must not own |
| --- | --- | --- |
| Domain (`IncomesLibrary`) | Validation, calculations, repeat rules, duplication planning, search predicate building, maintenance rules, SwiftData schema/predicates/descriptors | App-specific side effects (notifications, WidgetKit reload, ads, StoreKit, WatchConnectivity orchestration, lifecycle wiring) |
| Adapter (`Incomes`, `Watch`, `Widgets`, App Intents) | Parameter parsing, platform API calls, dependency wiring, follow-up orchestration based on domain outcomes | Domain branching duplicated from library |
| View (SwiftUI) | Focus state, sheets, navigation state, formatting, view composition | Domain validation branching, business calculations, repeat/duplication rules |

## View Rules

Allowed in views:

- Focus and keyboard behavior
- Sheet/dialog routing
- Navigation and transient UI state
- Display-only formatting

Not allowed in views:

- Domain validation branching
- Financial calculations
- Repeat series decision rules
- Duplication planning rules

## Canonical Mutation Flow

`View -> Workflow/Adapter (Incomes target) -> IncomesLibrary service -> SwiftData write -> Observation/@Query updates`

Adapters may orchestrate platform side effects after mutation completion, but mutation rules and changed-entity decisions come from `IncomesLibrary`.

## App Intent Mapping

App Intents must follow the same domain path:

`AppIntent parameter parsing -> same Workflow/Adapter -> same IncomesLibrary service`

Intent files may convert domain errors to App Intent errors, but must not re-implement domain rules.

## MutationOutcome Contract

Domain mutations should expose change metadata through `MutationOutcome`:

- `changedIDs` (`created`, `updated`, `deleted`)
- `affectedDateRange`
- `followUpHints` (`refreshNotificationSchedule`, `reloadWidgets`, `refreshWatchSnapshot`)

Adapters decide which platform actions to execute from `followUpHints`.

## SwiftData Boundary

Keep in `IncomesLibrary`:

- `@Model` types
- Predicates and `FetchDescriptor` builders
- Domain mutation/query logic

Keep in app targets:

- `ModelContainer` construction
- CloudKit on/off policy
- App/scene lifecycle wiring
- Platform side effects (notifications, widgets, watch bridge, ads, StoreKit)

API style decision:

- Continue accepting `ModelContext` in library APIs.
- Rationale: current codebase is `@Query`/Observation-first and already centered on `mainContext`; introducing `ModelActor` now would increase migration cost without directly improving this boundary policy.

## Current Hotspots and Minimal Refactor Plans

1. Yearly duplication coordinator keeps domain selection/application logic in app adapter.
   Files:
   - `Incomes/Sources/Settings/Models/YearlyDuplicationCoordinator.swift`
   - `Incomes/Sources/Settings/Views/YearlyDuplicationView.swift`
   Minimal plan:
   - Keep UI orchestration in coordinator.
   - Use `YearlyItemDuplicator.selectionState`, `YearlyItemDuplicator.apply(groupID:in:)`, and draft helper APIs from library.

2. Watch sync path performs direct CRUD and recalculation in watch target.
   File:
   - `Watch/Sources/Services/WatchDataSyncer.swift`
   Minimal plan:
   - Delegate snapshot application to `WatchSyncService.applySnapshot(...)` in `IncomesLibrary`.
   - Keep watch-side networking and trigger timing in adapter.

3. Repeat month rules are duplicated in UI and library.
   Files:
   - `Incomes/Sources/Item/Views/ItemFormView.swift`
   - `Incomes/Sources/Item/Components/RepeatMonthPicker.swift`
   - `IncomesLibrary/Sources/Item/ItemService.swift`
   Minimal plan:
   - Centralize validation/normalization in `RepeatMonthSelectionRules`.
   - Reuse the same rule set in both view and library mutation paths.

4. App Intents duplicate form validation and repeat month parsing.
   Files:
   - `Incomes/Sources/Item/Intents/Create/CreateItemIntent.swift`
   - `Incomes/Sources/Item/Intents/Create/CreateScheduledItemIntent.swift`
   - `Incomes/Sources/Item/Intents/Update/UpdateItemIntent.swift`
   Minimal plan:
   - Use `ItemFormInput.validate()` and `RepeatMonthSelectionParser` in `IncomesLibrary`.
   - Keep only App Intent-specific error conversion in intent files.

5. Search numeric range interpretation lives in UI model.
   Files:
   - `Incomes/Sources/Search/Models/SearchTarget.swift`
   - `Incomes/Sources/Search/Views/SearchListView.swift`
   Minimal plan:
   - Move numeric range to predicate mapping into `ItemSearchPredicateBuilder` in library.
   - Keep `SearchTarget` as presentation selection.
