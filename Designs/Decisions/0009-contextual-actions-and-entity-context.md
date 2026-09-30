# ADR 0009: Contextual Actions and Onscreen Entity Context

- Date: 2026-09-30
- Status: Accepted

## Context

Incomes uses SwiftUI context menus on item, month, year, search, and
maintenance rows. In iOS 27, the system adds an Ask Siri item to menus when
their content is relevant to Siri. That presentation belongs to the system.

App Intents already expose `ItemEntity` and `TagEntity`. SwiftUI's
`appEntityIdentifier(_:)` (iOS 18.4) and
`UNMutableNotificationContent.appEntityIdentifiers` (iOS 27) can tell the
system which of those entities a view or notification represents. Apple's
guidance applies them to content that shows a specific entity, such as a
detail view or the items of a list.

## Decision

1. The visible UI stays primary. Context menus add accelerators. Every menu
   action other than share, copy, and item recalculation also has a visible
   path: a tap target, a swipe or edit-mode delete, a detail-screen button, or
   a section header.
2. Menus follow one order: the primary or open action, secondary actions,
   share and copy, then destructive actions last behind a divider.
3. Ask Siri stays system-owned. Incomes adds no custom Ask Siri command and no
   menu that exists only to surface Siri.
4. Entity annotations are added only where a view represents one stored
   entity that the system cannot infer from visible text:
   - Item detail (`ItemView`) and item rows (`ListItemButton`) identify their
     `ItemEntity`. The rows carry the item context menu, so a request about
     "this item" from that menu resolves to the stored item.
   - Category and content item lists identify the `TagEntity` they show, so
     "this category" resolves for intents such as renaming a category.
   - Upcoming-payment notifications identify the `ItemEntity` they remind
     about on iOS 27.
5. These surfaces stay unannotated:
   - Year and month rows and summaries. Their titles already name the period,
     and the navigation tags behind them are not user-facing entities.
   - Search filter rows, which are transient filters.
   - Duplicate and orphan tag maintenance rows, whose identities are being
     resolved.
   - Charts.
6. Incomes publishes no `NSUserActivity`. Adding one only to carry an entity
   identifier would create an integration without its own purpose.

## Surface Audit

- Item rows: open, edit, duplicate, recalculate, share and copy link, and
  delete. Kept; annotated.
- Item detail: visible edit, duplicate, and delete buttons. No menu;
  annotated.
- Month rows: view month, share and copy link, and delete. Kept; swipe delete
  remains visible.
- Year sidebar rows and year summary row: show summary, duplicate year items,
  and share and copy link, with delete on sidebar rows. Kept.
- Search category and content rows: apply filter and copy name. Kept.
- Duplicate tag rows: open and copy name, then resolve. Reordered so the
  destructive resolve action is last; resolve stays visible in section
  headers.
- Orphan tag rows, yearly duplication proposals, and the Settings version
  row: kept as they are.

## Consequences

- Older supported OS versions keep the same menus and visible actions; the
  annotation helpers do nothing there.
- New item or tag screens should use `itemEntityIdentifier(_:)` or
  `tagEntityIdentifier(_:)` only when they show one stored entity.
- Runtime checks confirm the documented integration. A single OS build's Ask
  Siri behavior is not a reason to add annotations or overrides.

## References

- <https://developer.apple.com/documentation/swiftui/view/appentityidentifier(_:)>
- <https://developer.apple.com/documentation/appintents/adopting-app-intents-to-support-system-experiences>
- <https://developer.apple.com/videos/play/wwdc2026/278/>
