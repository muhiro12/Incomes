# ADR 0004: Views Own Presentation, Not Business Rules

- Date: 2026-03-04
- Status: Accepted

## Context

SwiftUI views are convenient places to add local decisions for deletion,
duplicate handling, date parsing, and yearly duplication flows. Over time,
those decisions become hard to reuse and easy to diverge from other surfaces.

## Decision

Views own presentation state, local interaction state, and navigation. Reusable
business decisions and mutations belong in shared services such as
`ItemService`, `TagService`, and `YearlyItemDuplicator`. App-side coordinators
may orchestrate UI flows, but they should delegate the actual rules.

## Consequences

- If a view reconstructs shared logic, that is a refactoring target.
- Thin coordinators are acceptable when they adapt shared services to a screen.
- Business rules used by views, App Intents, watchOS, or widgets should move
  toward shared service APIs.
- The app becomes easier to reason about because presentation code and business
  rules have clearer boundaries.
