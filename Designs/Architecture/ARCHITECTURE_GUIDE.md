# Incomes Architecture Guide

## Scope

This guide defines the strict `business-logic-in-library, UI-as-adapter`
policy for this repository. `IncomesLibrary` is the app's behavioral
implementation: business rules, persistence schema, shared value contracts,
and tested decision-making live there. `Incomes`, `Watch`, `Widgets`, App
Intents, and Shortcuts are delivery surfaces that adapt the shared
implementation to Apple frameworks and user interfaces.

Related document:
[shared-service-design.md](./shared-service-design.md)

Related decision:
[0005-adapter-failure-surfacing-contract.md](../Decisions/0005-adapter-failure-surfacing-contract.md)

Related decision:
[0006-operations-as-business-use-case-boundary.md](../Decisions/0006-operations-as-business-use-case-boundary.md)

## Public Business Boundary

External delivery surfaces call business use cases through public
`*Operations` facades in `IncomesLibrary`.

`Operations` is the library's application layer. It may orchestrate models,
value types, calculators, builders, planners, loaders, parsers, codecs, and
persistence queries, but those collaborators should not become the primary
public business interface for app, intent, watch, or widget surfaces.

Public non-Operations contracts remain valid when they are value types, route
or deep-link contracts, wire payloads, snapshot models, parsers, codecs,
persistence setup, or development/platform support rather than externally
invoked business use cases.

## Responsibility Boundaries

| Layer | Owns | Must not own |
| --- | --- | --- |
| Business implementation (`IncomesLibrary`) | Public `*Operations` facades, validation, calculations, repeat rules, duplication planning, search predicate building, maintenance rules, SwiftData schema/predicates/descriptors, shared route and sync contracts | App-specific side effects (notifications, WidgetKit reload, ads, StoreKit, WatchConnectivity orchestration, lifecycle wiring), UI framework types, App Intent types |
| Collaborator (`IncomesLibrary`) | Models, value types, calculators, builders, planners, loaders, parsers, codecs, and persistence helpers used by `*Operations` | Primary external business-use-case entry points |
| Delivery surface / adapter (`Incomes`, `Watch`, `Widgets`, App Intents) | Parameter parsing, platform API calls, dependency wiring, follow-up orchestration based on operation outcomes | Business branching duplicated from library |
| View (SwiftUI) | Focus state, sheets, navigation state, screen-scoped `@Observable` presentation models, formatting, view composition | Business validation branching, financial calculations, repeat/duplication rules |

## Thin-Target Clarification

- "Thin target" in this repository means responsibility-thin, not
  line-count-thin.
- `Incomes`, `Watch`, `Widgets`, and App Intents may legitimately own SwiftUI
  shells, route intake, lifecycle wiring, WatchConnectivity transport,
  notification delivery, and other Apple-framework adapters.
- A target is still considered thin when reusable finance rules, mutation
  decisions, shared snapshot building, and sync wire contracts continue to live
  in `IncomesLibrary` and external business calls enter through `*Operations`.
- A serious behavioral defect should be reproducible in `IncomesLibrary` tests.
  If a defect can only exist in one surface, it should usually be limited to
  presentation, platform delivery, or adapter wiring.

## Testing Boundary

- Keep automated tests in `IncomesLibrary/Tests`.
- Do not maintain separate unit test targets for `Incomes`, `Watch`, or
  `Widgets`. App-owned adapters should stay thin enough to verify through
  builds and library-owned decision-rule coverage.
- Do not add unit tests for screen-scoped presentation models, routers, or
  thin coordinators by default. If one of those areas needs durable coverage,
  first move the reusable rule into `IncomesLibrary` and test it there.
- When adapter flows need durable sync or serialization coverage, move the wire
  contract into `IncomesLibrary` and test it there instead of growing
  target-local test suites.

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

App Intents must follow the same business path:

`AppIntent parameter parsing -> same Workflow/Adapter -> IncomesLibrary *Operations`

Intent files may convert operation errors to App Intent errors, but must not re-implement business rules.
Intent-only entities, parameter summaries, snippet views, and shortcut phrases
stay outside `IncomesLibrary` because they are adapter concerns.

The same adapter rule applies to `Watch` and `Widgets`:

- `Watch` should keep transport, timing, and small screen models locally while
  delegating shared item queries, snapshot apply rules, and sync reply models
  to `IncomesLibrary`.
- `Widgets` should keep timeline providers and entry presentation locally while
  delegating shared calculations and snapshot building to `IncomesLibrary`.

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

Current shared sync contract and snapshot services:

- `ItemsRequest`
- `WatchSyncReply`
- `WatchSyncFailure`
- `WatchSyncFailurePhase`
- `WatchSyncOperations.recentItemWires(context:baseDate:monthOffsets:)`
- `WatchSyncOperations.applySnapshot(context:items:baseDate:monthOffsets:)`

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

2. Notification delivery contracts must keep shared payload and identifier
   rules in the library while framework delivery stays adapter-owned.
   File:
   - `Incomes/Sources/Notification/Services/NotificationService.swift`
   - `Incomes/Sources/Notification/Services/NotificationService+RouteDelivery.swift`
   - `IncomesLibrary/Sources/Notification/NotificationRoutePayload.swift`
   - `IncomesLibrary/Sources/Notification/UpcomingPaymentNotificationPresentation.swift`
   Minimal plan:
   - Keep payload codec, metadata keys, action route identifiers, legacy month
     fallback logic, and upcoming-payment request identifier matching in
     `IncomesLibrary`.
   - Keep `UNUserNotificationCenter` categories, authorization, scheduling,
     and content assembly in `NotificationService`.
   - Keep notification response delivery in `NotificationService+RouteDelivery`
     by decoding the shared payload contract and delivering route URLs through
     `IncomesRouteBridge` instead of storing app-local pending routes.

3. Generic mutation follow-up execution must stay separate from
   feature-specific mutation projections.
   Files:
   - `Incomes/Sources/Common/Services/IncomesMutationWorkflow.swift`
   - `Incomes/Sources/Item/Services/ItemMutationAdapterFactory.swift`
   - `Incomes/Sources/Item/Services/ItemFormSaveCoordinator.swift`
   - `Incomes/Sources/Settings/Coordinators/YearlyDuplicationCoordinator.swift`
   Minimal plan:
   - Keep generic follow-up hint execution in
     `IncomesMutationWorkflow`.
   - Use `MHMutationWorkflow.runThrowing(... projection:)` directly in
     coordinators instead of app-local wrapper APIs.
   - Keep item mutation side effects out of the generic follow-up adapter.
     `ItemMutationAdapterFactory` may assemble item-specific save/delete
     adapters, but its public entrypoints should stay purpose-specific rather
     than boolean-driven.
   - Keep save-specific haptics and review scheduling explicit in the save
     adapter path, and keep delete-specific adapters review-free.

4. Watch sync should keep using the shared snapshot service rather than
   reintroducing target-local snapshot or mutation rules.
   Files:
   - `Watch/Sources/Services/WatchDataSyncer.swift`
   - `IncomesLibrary/Sources/Item/Sync/WatchSyncOperations.swift`
   Minimal plan:
   - Keep networking/timing in watch adapters.
   - Keep response snapshot building, snapshot apply, and reconciliation in
     `WatchSyncOperations`.
