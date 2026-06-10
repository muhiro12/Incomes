# Shared Service Design

## Purpose

This document describes the boundary between the shared implementation and the
delivery surfaces in Incomes. It explains where new code should live when the
same business use case must work across the iOS app, App Intents, Apple Watch,
and widgets.

## Core Principles

- `IncomesLibrary` is the behavioral source of truth for the product.
- Public business use cases that delivery surfaces call are exposed through
  `*Operations` facades.
- `Incomes` owns SwiftUI presentation and adapters for Apple frameworks.
- `AppIntent` types are adapters, not a second domain layer.
- Views keep presentation state and navigation, but reusable business decisions
  and mutations belong in shared operations.
- Delivery surfaces should be able to fail visually or operationally without
  invalidating the domain behavior covered by `IncomesLibrary` tests.
- `IncomesLibrary` remains a single module unless there is a stronger reason
  than code organization alone.
- Thin targets here are responsibility-thin. They may still contain UI shells,
  lifecycle wiring, and framework adapters so long as reusable rules stay in
  `IncomesLibrary`.

## Responsibility Boundaries

| Concern | Lives in | Examples |
| --- | --- | --- |
| Business operations | `IncomesLibrary` | `Item*Operations`, `Tag*Operations`, `ItemSummaryOperations`, `YearlyItemDuplication*Operations`, `WidgetEntryOperations`, `WatchSyncOperations`, `UpcomingPaymentOperations`, `SettingsStatusOperations`, `DataMaintenanceOperations` |
| Library collaborators and contracts | `IncomesLibrary` | `Item`, `Tag`, predicates, calculators, builders, planners, loaders, parsers, codecs, route contracts, wire payloads, snapshot models |
| Apple framework adapters | `Incomes` | `ItemInferenceService`, `NotificationService`, App Intent types, deep-link routing, StoreKit, ads |
| App-side platform support | `Incomes/Sources/Common/Platform` | `IncomesPlatformEnvironmentFactory`, `MHAppRuntimeBootstrap` assembly, `MHAppRoutePipeline<IncomesRoute>` assembly, `IncomesRouteBridge`, `MHReviewFlow` policy helpers |
| Watch and widget surfaces | `Watch`, `Widgets` | WatchConnectivity transport, widget timeline providers, target-local screen state, entry presentation |
| Presentation orchestration | `Incomes` | SwiftUI views, navigation state, form state, app-side services in `Item/Services`, and coordinators in `Settings/Coordinators` |

## MHPlatform Adoption

- `Incomes` is the intentional `MHPlatform` umbrella adopter.
- `IncomesLibrary` adopts `MHPlatformCore` and must not depend on the
  full `MHPlatform` umbrella.
- `Watch` intentionally stays on the narrower `MHPreferences` product.
- `Widgets` intentionally stay off direct MHPlatform package adoption.
- This repository intentionally uses the MHPlatform 1.x semver range
  `1.0.0..<2.0.0`.

## Canonical Shared APIs

The following types are the current shared entry points for business
operations and shared wire contracts:

- `ItemFormInput`
- `ItemMutationScope`
- `RepeatMonthSelectionOperations`
- `ItemCreationOperations` repeat count limits
- `Item*Operations.create(context:input:repeatMonthSelections:)`
- `Item*Operations.requiresScopeSelection(context:item:)`
- `Item*Operations.update(context:item:input:scope:)`
- `Tag*Operations` duplicate-resolution, tag/date lookup, category display, and display matching helpers
- `YearlyItemDuplicationPlanOperations.plan(context:sourceYear:targetYear:)`
- `YearlyItemDuplicationApplyOperations.apply(plan:context:)`
- `YearlyDuplicationAutomationOperations`
- `YearlyDuplicationPresentationOperations`
- `YearlyDuplicationPromoOperations`
- `ItemSummaryOperations`
- `SearchResultOperations`
- `MainNavigationOperations` route and state resolution
- `WidgetEntryOperations`
- `WatchSyncOperations`
- `UpcomingPaymentOperations`
- `MonthlySummaryOperations` context, prompt, language, and fallback handling
- `ItemFormInferenceOperations`
- `SettingsStatusOperations`
- `DataMaintenanceOperations`
- `SubscriptionStateOperations`
- `NotificationRoutePayload`
- `UpcomingPaymentNotificationPresentation`
- `ItemsRequest`
- `WatchSyncReply`
- `WatchSyncFailure`
- `WatchSyncFailurePhase`

App-side mutation call sites should prefer
`MHMutationWorkflow.runThrowing(... projection:)` over local wrapper APIs.

## Placement Rules

1. If an operation defines product behavior, add or extend a library
   `*Operations` facade first.
2. If an operation depends on Apple-only frameworks, keep it in `Incomes` and
   make it call library APIs.
3. If a view, intent, widget, or watch target starts calling helper
   collaborators or recreating date parsing, duplicate resolution, yearly
   duplication planning, or mutation rules, treat that as a missing operation.
4. Keep platform-specific types out of `IncomesLibrary`. Convert them at the
   boundary into library models or value types.
5. Shared serialization contracts used by multiple targets belong in
   `IncomesLibrary`, even when transport happens through Apple-only APIs such as
   WatchConnectivity.
6. Treat hidden intents as acceptable when the capability is useful but the
   shortcut should not be broadly discoverable.
7. If glue code is app-only but reused by multiple app entry points, factor it
   into `Incomes/Sources/Common/Platform` instead of moving it into
   `IncomesLibrary`.

## Test Posture

- Keep repository-owned unit tests in `IncomesLibrary/Tests`.
- Do not add separate unit test targets for `Incomes`, `Watch`, or `Widgets`
  unless the repository policy itself changes.
- If an adapter needs durable coverage, first extract the reusable rule or wire
  contract into `IncomesLibrary` and test it there.
- A broken surface should normally be a UI, routing, dependency wiring, or
  platform-delivery failure. Business behavior regressions should be caught by
  `IncomesLibrary` tests.

## Current Examples

- `ItemInferenceService` depends on Foundation Models, so it stays in
  `Incomes` and returns values that fit the shared item form flow.
- `MonthlySummaryGenerator` depends on Foundation Models, so it stays in
  `Incomes` while prompt construction, fallback summaries, validation, and
  deterministic context loading stay behind `MonthlySummaryOperations`.
- `NotificationService` stays in `Incomes` and uses shared notification
  planning operations, presentation contracts, identifier rules, and route
  payload contracts from `IncomesLibrary`.
- `IncomesPlatformEnvironmentFactory` stays in `Incomes` because runtime,
  route pipeline, and review flow assembly depend on the `MHPlatform` umbrella, app
  secrets, and SwiftUI environment injection.
- `PhoneWatchBridge` and `PhoneSyncClient` stay in the app targets because they
  own WatchConnectivity transport, while `WatchSyncReply` and
  `WatchSyncOperations` stay in `IncomesLibrary` because the sync contract,
  response snapshot building, and apply rules are shared.
- `IncomesLibrary` stays on `MHPlatformCore` so shared logic only sees
  core-safe platform helpers.
- `ContentView` stays thin because `MHAppRuntimeBootstrap` owns the runtime,
  lifecycle, and route-drain shell.
- `MainNavigationView` registers its route handler through `IncomesRouteBridge`
  so the package owns route intake while the app still owns navigation meaning.
- `YearlyDuplicationCoordinator` stays under `Settings/Coordinators` as an app-side adapter that delegates
  duplication rules to `YearlyItemDuplication*Operations` and uses package-owned mutation
  projection strategies.
- `ItemFormSaveCoordinator` stays under `Item/Services`, converts UI state into
  `ItemFormInput`, and calls canonical `Item*Operations` APIs through
  `MHMutationWorkflow.runThrowing`.
- `ItemMutationAdapterFactory` stays app-side because it combines generic
  follow-up hint execution with item-specific haptics and review requests. Its
  public entrypoints should describe the mutation purpose, such as save or
  delete, instead of accepting boolean feature toggles.

## Refactoring Heuristic

When a business rule is duplicated, the default fix is to move the rule into
`IncomesLibrary` and expose it through `*Operations` rather than duplicating it
in another view, intent, or target.
When the duplicated code is still Apple-framework glue, the default fix is to
extract it into `Incomes/Sources/Common/Platform`.
