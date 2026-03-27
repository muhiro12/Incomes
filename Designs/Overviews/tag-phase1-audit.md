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

## Confirmed Phase 2 Risk

- Orphaned tags remain after item updates and deletes.
- This was reproduced on March 27, 2026 with Xcode snippet execution against
  `Incomes.xcodeproj` without mutating repository files.
- Updating a single item from `Old Content` and `Old Category` to
  `New Content` and `New Category` left both the old and new content/category
  tags in the store.
- Deleting that same item afterward still left six tags in the store.
- Relevant code paths are `IncomesLibrary/Sources/Item/Item.swift` and
  `IncomesLibrary/Sources/Item/ItemService.swift`.
- Phase 1 does not change this behavior. Cleanup and orphan-tag policy are
  deferred to phase 2.

## Coverage Added In Phase 1

- Reuse of existing tags for identical name and type pairs.
- Active derived-tag composition after item modification.
- Duplicate-warning status after duplicate resolution.
- Shared display and matching helper coverage for formatted display names,
  kana-aware stored-name matching, and display-name filtering behavior.
