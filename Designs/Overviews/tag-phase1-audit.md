# Tag Phase 1 Audit

## Scope

This note records the phase 1 audit for tag behavior, design alignment, and
regression coverage. The phase focuses on confirmation and passing regression
tests, not production behavior changes.

## Confirmed Contracts

- Derived tags remain the main indexing contract for `year`, `yearMonth`,
  `content`, and `category`.
- Duplicate-tag maintenance still resolves the settings warning once duplicate
  groups are merged.
- Shared tag display and matching rules now live in one library helper and back
  `Tag`, `TagPredicate`, `TagEntityQuery`, and app-side search filtering.

## Phase 2 Risk Resolution

- Item updates and deletes now collect the affected derived tags and remove
  those that no longer have any items.
- The cleanup is part of the same explicit save-or-rollback mutation boundary
  as the item change, so a persistence failure cannot leave a partially applied
  item/tag result.
- Time-zone regression coverage verifies cleanup after both single-item update
  and deletion paths.

## Coverage Added In Phase 1

- Reuse of existing tags for identical name and type pairs.
- Active derived-tag composition after item modification.
- Duplicate-warning status after duplicate resolution.
- Shared display and matching helper coverage for formatted display names,
  kana-aware stored-name matching, and display-name filtering behavior.
