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

1. App lifecycle and runtime wiring should stay in app-side platform support, not in root app/view files.
   Files:
   - `Incomes/Sources/IncomesApp.swift`
   - `Incomes/Sources/ContentView.swift`
   - `Incomes/Sources/Debug/Models/IncomesSampleData.swift`
   - `Incomes/Sources/Common/Platform/*`
   Minimal plan:
   - Keep `MHAppRuntime`, review policy, and pending deep-link source-chain setup in app-only support helpers.
   - Keep `IncomesApp` and `ContentView` focused on dependency injection, scene wiring, and UI state updates.

2. Notification route payload configuration must stay defined in one adapter helper.
   File:
   - `Incomes/Sources/Notification/Models/NotificationService.swift`
   - `Incomes/Sources/Notification/Models/NotificationService+RouteDelivery.swift`
   - `Incomes/Sources/Notification/Models/NotificationRoutePayload.swift`
   Minimal plan:
   - Keep payload codec, metadata keys, and legacy month fallback logic in a single adapter helper.
   - Keep `UNUserNotificationCenter` integration and presentation assembly in `NotificationService`.

3. Generic mutation workflow helpers must stay separate from item-form-specific side effects.
   Files:
   - `Incomes/Sources/Common/Services/IncomesMutationWorkflow.swift`
   - `Incomes/Sources/Item/Models/ItemFormSaveCoordinator.swift`
   Minimal plan:
   - Keep generic follow-up hint execution in `IncomesMutationWorkflow`.
   - Keep save-specific haptics and review scheduling in `ItemFormSaveCoordinator`.

4. Watch sync should keep using the shared snapshot service rather than reintroducing target-local mutation rules.
   Files:
   - `Watch/Sources/Services/WatchDataSyncer.swift`
   - `IncomesLibrary/Sources/Item/Sync/WatchSyncService.swift`
   Minimal plan:
   - Keep networking/timing in watch adapters.
   - Keep snapshot apply and reconciliation in `WatchSyncService`.
