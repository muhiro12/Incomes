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
| Presentation orchestration | `Incomes` | SwiftUI views, navigation state, form state, coordinators such as `ItemFormSaveCoordinator` and `YearlyDuplicationCoordinator` |

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

Compatibility wrappers may remain temporarily, but new call sites should use
the canonical APIs above.

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

## Current Examples

- `ItemInferenceService` depends on Foundation Models, so it stays in
  `Incomes` and returns values that fit the shared item form flow.
- `NotificationService` stays in `Incomes` and uses shared planning logic from
  `IncomesLibrary`.
- `YearlyDuplicationCoordinator` is an app-side adapter that delegates
  duplication rules to `YearlyItemDuplicator`.
- `ItemFormSaveCoordinator` converts UI state into `ItemFormInput` and calls
  canonical `ItemService` APIs.

## Refactoring Heuristic

When a business rule is duplicated, the default fix is to move the rule into
`IncomesLibrary` rather than duplicating it in another view, intent, or target.
