# ADR 0010: Semantic Navigation Restoration

- Date: 2026-09-30
- Status: Accepted

## Context

Incomes opens on today's year and month. When the system ends a suspended
scene, a person returning to the app should see the year or month they were
reviewing. Links, widgets, notifications, and App Intents also open specific
destinations, and those explicit requests must not lose to stale state.

`NavigationSplitView` column geometry and internal view state change with size
classes and OS releases, so they are poor candidates for persistence.

## Decision

Restore the semantic selection, not view internals.

- Durable within a scene: the selected year, year summary, or month. The main
  view stores it as the canonical deep link for `IncomesRoute.year`,
  `.yearSummary`, or `.month` in `@SceneStorage`.
- Session-only: search text and filters, the item detail sheet, Settings,
  yearly duplication, and tag maintenance screens.
- Never restored: the preferred compact column, which is derived from the
  restored selection, and unsaved item form input, which follows the form's
  own save and discard contract.

Launch order:

1. Select today's year and month.
2. Apply the restored route when the scene has one. A deleted year keeps
   today's default; a deleted month falls back to its year.
3. An incoming route always wins. If it arrives before the initial state, the
   default and the restored route are skipped; if it arrives later, it replaces
   them.

`@SceneStorage` follows the system's scene lifecycle. The stored selection
lives as long as the scene session: on iPhone it survives background
termination and relaunch, including a quit from the app switcher, while a
scene the system destroys, such as a closed iPad or Mac window, starts again
from today's month. Incomes adds no separate persistence or expiry on top of
that lifecycle.

## Consequences

- Restoration reuses `IncomesRouteParser` and the route executor, so a stored
  route resolves exactly like the same deep link.
- A stored route that a future version no longer restores is ignored.
- Compact and regular layouts both restore the same semantic selection.
- `MainNavigationOperations.restorableRoute(yearTag:selectedTag:)`,
  `restorationURL(for:)`, and `restorableRoute(from:)` are the only entry
  points for restorable state.
