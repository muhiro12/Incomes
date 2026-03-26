# Incomes Architecture Guide

## Scope

This guide defines the strict `domain-in-library, UI-as-adapter` policy for this repository.

Related document:
[shared-service-design.md](./shared-service-design.md)

Related decision:
[0005-adapter-failure-surfacing-contract.md](../Decisions/0005-adapter-failure-surfacing-contract.md)

## Responsibility Boundaries

| Layer | Owns | Must not own |
| --- | --- | --- |
| Domain (`IncomesLibrary`) | Validation, calculations, repeat rules, duplication planning, search predicate building, maintenance rules, SwiftData schema/predicates/descriptors | App-specific side effects (notifications, WidgetKit reload, ads, StoreKit, WatchConnectivity orchestration, lifecycle wiring) |
| Adapter (`Incomes`, `Watch`, `Widgets`, App Intents) | Parameter parsing, platform API calls, dependency wiring, follow-up orchestration based on domain outcomes | Domain branching duplicated from library |
| View (SwiftUI) | Focus state, sheets, navigation state, screen-scoped `@Observable` presentation models, formatting, view composition | Domain validation branching, business calculations, repeat/duplication rules |

## Testing Boundary

- Keep automated tests in `IncomesLibrary/Tests`.
- Do not maintain a separate app-target unit test suite. App-owned adapters
  should stay thin enough to verify through app builds and library-owned
  decision-rule coverage.
- Do not add unit tests for screen-scoped presentation models, routers, or
  thin coordinators by default. If one of those areas needs durable coverage,
  first move the reusable rule into `IncomesLibrary` and test it there.

## View Rules

Allowed in views:

- Focus and keyboard behavior
- Sheet/dialog routing
- Navigation and transient UI state
- Small screen-scoped `@Observable` models owned by the root view
- Display-only formatting

Not allowed in views:

- Domain validation branching
- Financial calculations
- Repeat series decision rules
- Duplication planning rules

## Screen-Scoped Presentation Models

When a screen grows beyond trivial local state, keep a small `@Observable`
presentation model in the root view's `@State` and pass it downward with
`@Bindable` or typed `@Environment(Type.self)`.

Prefer this over:

- `ObservableObject`
- `EnvironmentObject`
- adding feature-local sheet or dismissal sequencing into a broader router

Current examples include `MainNavigationRouter`,
`MainNavigationSettingsCoordinator`, `MainNavigationYearDeletionModel`,
`SettingsScreenModel`, `ItemFormPresentationModel`, and
`WatchHomeScreenModel`.

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

## Failure-Surfacing Contract

Adapter-owned mutation and sync paths must classify failures by phase rather
than relying on assertions or empty sentinel values.

- Preflight and primary mutation failures block success and must be surfaced to
  the current caller.
- Post-commit follow-up failures are degraded-success cases: keep the committed
  mutation result, but emit observable failure signals and prefer repairable
  retries.
- Sync transport, decode, and apply failures must stay distinguishable from a
  legitimate zero-data snapshot.

See
[0005-adapter-failure-surfacing-contract.md](../Decisions/0005-adapter-failure-surfacing-contract.md)
for the repository-level contract.

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

1. App runtime integration should use the package-owned shells, and the
   main navigation screen should stay decomposed into focused presentation
   helpers.
   Files:
   - `Incomes/Sources/IncomesApp.swift`
   - `Incomes/Sources/ContentView.swift`
   - `Incomes/Sources/Debug/Models/IncomesSampleData.swift`
   - `Incomes/Sources/Common/Platform/*`
   - `Incomes/Sources/Main/Views/MainNavigationView.swift`
   - `Incomes/Sources/Main/Views/MainNavigationSidebarView.swift`
   - `Incomes/Sources/Main/Views/MainNavigationContentColumn.swift`
   - `Incomes/Sources/Main/Views/MainNavigationDetailColumn.swift`
   - `Incomes/Sources/Main/Views/MainNavigationSheetPresenter.swift`
   - `Incomes/Sources/Main/Views/MainNavigationRouter.swift`
   - `Incomes/Sources/Main/Views/MainNavigationSettingsCoordinator.swift`
   - `Incomes/Sources/Main/Views/MainNavigationYearDeletionModel.swift`
   Minimal plan:
   - Keep `IncomesPlatformEnvironmentFactory` focused on assembling
     `MHAppRuntimeBootstrap`, `MHAppRoutePipeline<IncomesRoute>`,
     `IncomesRouteBridge`, `MHReviewFlow`, and app services.
   - Keep `ContentView` focused on UI state synchronization and update
     alert presentation.
   - Keep `MainNavigationView` as a thin `NavigationSplitView`
     composition root that registers the route handler after loading
     persisted state.
   - Keep sidebar, content, detail, and sheet presentation split across
     dedicated view files.
   - Keep `MainNavigationRouter` limited to navigation state and route
     application.
   - Keep settings-dismissal deferral and similar flow sequencing in
     `MainNavigationSettingsCoordinator` instead of expanding router
     responsibility.

2. Notification route payload configuration must stay defined in one adapter helper.
   File:
   - `Incomes/Sources/Notification/Services/NotificationService.swift`
   - `Incomes/Sources/Notification/Services/NotificationService+RouteDelivery.swift`
   - `Incomes/Sources/Notification/Routing/NotificationRoutePayload.swift`
   Minimal plan:
   - Keep payload codec, metadata keys, and legacy month fallback logic
     in a single adapter helper.
   - Keep `UNUserNotificationCenter` integration and presentation
     assembly in `NotificationService`.
   - Deliver decoded route URLs into the package-owned route pipeline
     through `IncomesRouteBridge` instead of storing app-local pending routes.

3. Generic mutation follow-up execution must stay separate from
   feature-specific mutation projections.
   Files:
   - `Incomes/Sources/Common/Services/IncomesMutationWorkflow.swift`
   - `Incomes/Sources/Item/Services/ItemFormSaveCoordinator.swift`
   - `Incomes/Sources/Settings/Coordinators/YearlyDuplicationCoordinator.swift`
   Minimal plan:
   - Keep generic follow-up hint execution in
     `IncomesMutationWorkflow`.
   - Use `MHMutationWorkflow.runThrowing(... projection:)` directly in
     coordinators instead of app-local wrapper APIs.
   - Keep save-specific haptics and review scheduling in
     `ItemFormSaveCoordinator`.

4. Watch sync should keep using the shared snapshot service rather than reintroducing target-local mutation rules.
   Files:
   - `Watch/Sources/Services/WatchDataSyncer.swift`
   - `IncomesLibrary/Sources/Item/Sync/WatchSyncService.swift`
   Minimal plan:
   - Keep networking/timing in watch adapters.
   - Keep snapshot apply and reconciliation in `WatchSyncService`.
