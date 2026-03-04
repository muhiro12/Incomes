# ADR 0001: Shared Library Source of Truth

- Date: 2026-03-04
- Status: Accepted

## Context

Incomes supports the same business operations through multiple surfaces:
SwiftUI screens, App Intents, Apple Watch, widgets, and background flows. When
those surfaces each grow their own mutation or decision logic, behavior drifts
and refactoring becomes expensive.

## Decision

`IncomesLibrary` is the single source of truth for reusable business logic.
Shared models, predicates, calculators, planners, and mutation services belong
there. The module stays as one shared library for now.

## Consequences

- Shared operations should be expressed through library services before they
  are reused elsewhere.
- `ItemService`, `TagService`, `YearlyItemDuplicator`, `SummaryCalculator`, and
  `DataMaintenanceService` are primary shared entry points.
- UI, App Intents, watchOS, and widgets should call the same shared APIs.
- Compatibility wrappers may exist during migration, but new call sites should
  target the canonical shared APIs.
