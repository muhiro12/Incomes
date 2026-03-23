# Shared Service Design

## Purpose

This document describes the current boundary for shared business logic in
Incomes. It explains where new code should live when the same operation must
work across the iOS app, App Intents, Apple Watch, and widgets.

## Core Principles

- `IncomesLibrary` is the source of truth for shared business logic.
- `Incomes` owns SwiftUI presentation and adapters for Apple frameworks.
- `AppIntent` types are adapters, not a second domain layer.
- Views keep presentation state and navigation, but reusable business decisions
  and mutations belong in shared services.
- `IncomesLibrary` remains a single module unless there is a stronger reason
  than code organization alone.

## Responsibility Boundaries

| Concern | Lives in | Examples |
| --- | --- | --- |
| Shared domain logic | `IncomesLibrary` | `Item`, `Tag`, predicates, `ItemService`, `TagService`, `SummaryCalculator`, `YearlyItemDuplicator`, `DataMaintenanceService`, `UpcomingPaymentPlanner`, `SettingsStatusLoader` |
| Apple framework adapters | `Incomes` | `ItemInferenceService`, `NotificationService`, App Intent types, deep-link routing, StoreKit, ads |
| App-side platform support | `Incomes/Sources/Common/Platform` | `IncomesPlatformEnvironmentFactory`, `MHAppRuntimeBootstrap` assembly, `MHAppRoutePipeline<IncomesRoute>` assembly, `IncomesRouteBridge`, `MHReviewFlow` policy helpers |
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
operations:

- `ItemFormInput`
- `ItemMutationScope`
- `ItemService.create(context:input:repeatMonthSelections:)`
- `ItemService.update(context:item:input:scope:)`
- `TagService` duplicate-resolution and tag/date lookup helpers
- `YearlyItemDuplicator.plan(context:sourceYear:targetYear:)`
- `YearlyItemDuplicator.apply(plan:context:)`
- `SummaryCalculator`
- `DataMaintenanceService.deleteAllData(context:)`
- `DataMaintenanceService.deleteDebugData(context:)`

App-side mutation call sites should prefer
`MHMutationWorkflow.runThrowing(... projection:)` over local wrapper APIs.

## Placement Rules

1. If an operation is reusable across more than one surface, add or extend a
   library service first.
2. If an operation depends on Apple-only frameworks, keep it in `Incomes` and
   make it call library APIs.
3. If a view or intent starts recreating date parsing, duplicate resolution,
   yearly duplication planning, or mutation rules, treat that as a missing
   library API.
4. Keep platform-specific types out of `IncomesLibrary`. Convert them at the
   boundary into library models or value types.
5. Treat hidden intents as acceptable when the capability is useful but the
   shortcut should not be broadly discoverable.
6. If glue code is app-only but reused by multiple app entry points, factor it
   into `Incomes/Sources/Common/Platform` instead of moving it into
   `IncomesLibrary`.

## Current Examples

- `ItemInferenceService` depends on Foundation Models, so it stays in
  `Incomes` and returns values that fit the shared item form flow.
- `NotificationService` stays in `Incomes` and uses shared planning logic from
  `IncomesLibrary`.
- `IncomesPlatformEnvironmentFactory` stays in `Incomes` because runtime,
  route pipeline, and review flow assembly depend on the `MHPlatform` umbrella, app
  secrets, and SwiftUI environment injection.
- `IncomesLibrary` stays on `MHPlatformCore` so shared logic only sees
  core-safe platform helpers.
- `ContentView` stays thin because `MHAppRuntimeBootstrap` owns the runtime,
  lifecycle, and route-drain shell.
- `MainNavigationView` registers its route handler through `IncomesRouteBridge`
  so the package owns route intake while the app still owns navigation meaning.
- `YearlyDuplicationCoordinator` stays under `Settings/Coordinators` as an app-side adapter that delegates
  duplication rules to `YearlyItemDuplicator` and uses package-owned mutation
  projection strategies.
- `ItemFormSaveCoordinator` stays under `Item/Services`, converts UI state into `ItemFormInput`, and calls
  canonical `ItemService` APIs with package-owned mutation and review shells.

## Refactoring Heuristic

When a business rule is duplicated, the default fix is to move the rule into
`IncomesLibrary` rather than duplicating it in another view, intent, or target.
When the duplicated code is still Apple-framework glue, the default fix is to
extract it into `Incomes/Sources/Common/Platform`.
