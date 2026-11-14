# Item ordering consumer audit

Follow-up to [the same-day balance investigation](same-day-item-order.md) for
[#420](https://github.com/muhiro12/Incomes/issues/420), on 2026-11-13.
This audit covers Incomes, its shared library, Watch, and Widgets. It distinguishes
financial sequence from canonical file comparison and ranked group summaries.

## Confirmed mismatches

| Consumer | Previous behavior and impact | Correction |
| --- | --- | --- |
| Notification planning and presentation | The shared reminder planner and presentation adapter reordered same-delivery-time Items by encoded identity. Priority and localized numeric names no longer matched the query. | Preserve delivery time as the primary scheduling key, then use the shared Item descriptors. Assign presentation badges in that final order. Keep request IDs, routes, eligibility, delivery dates, and limits unchanged. |
| Import duplicate matching | Fully equal stored records were ordered by the debug description of their native IDs. This changed which identity was retained or removed, and made review snapshots depend on a non-contractual representation. | Keep canonical value matching, then compare native identities directly for equal values. |
| Watch snapshots | The wire payload omitted priority, and the receiver recreated every Item with priority zero. | Carry priority through encoding and decoding into the recreated Item. Older payloads without this field retain their previous zero default. |
| File canonicalization | Missing balance and zero balance compared as equal despite representing distinct values. Reversing the input could change encoded bytes. | Order missing balance before present balance, preserving both values. This is a file-value comparison defect, not a financial sequence change. |
| Balance chart accessibility | The latest Item was selected by date alone. The selected row could differ from the final financial row on that day. | Use Item's shared reverse comparison to select the latest row, including priority, localized content, and native identity. |

The first four behaviors have regression tests of the production operations.
Temporarily restoring their previous implementations made those tests fail on
the intended assertions. The chart's selector is covered by native-query versus
Item-comparison assertions and an app build; VoiceOver output was not exercised.

## Incomplete order and consistency corrections

| Consumer | Finding | Action |
| --- | --- | --- |
| Yearly duplication source entries | Only target date was sorted after dictionary grouping. Equal-date source entries retained incidental group iteration order. | Use target date plus the source Item's priority, content, and native identity through the shared descriptor factory. Repeated planning is covered by a regression test that failed with the previous comparator. |
| Ledger balance snapshots | Already correct after the previous Comparable fix, but chronological intent was expressed indirectly as `sorted(by: >)`. | Use forward Item descriptors explicitly. |
| Tag Item lists | Already correct through Comparable, but reverse financial order was implicit in `sorted()`. | Use reverse Item descriptors explicitly. |
| Duplicate-ledger merge validation | Already correct through Comparable; arithmetic preflight depends on financial sequence. | Use forward descriptors explicitly. |
| Export preparation and import balance application | Already correct through Comparable, but relied on the inverted comparison spelling. | Use forward descriptors explicitly. |
| Import replace preview | Independently sorted only by date and raw content, unlike the complete value order used by other import reviews. No running balances are displayed in these rows. | Move the combined preview inventory into library operations and use canonical file-value order. Preserve review indices and matching decisions. |

Yearly source entry order is not a promise about new store identities. The yearly
apply operation still uses group-average amounts and its existing priority-zero
policy. Those product choices were not changed by this audit.

## Reviewed paths that retain their ordering

- Phone ledger lists, debug inventories, unassigned Items, native Watch queries,
  next/previous queries, Widgets, and encoded-ID query results already use the
  shared Item descriptors. Single-ID lookups need no sort.
- Search sections preserve the input Item sequence while sorting month headings.
  Their production callers supply native query results. Tag lists, search,
  next/previous queries, and ledger snapshots are covered together against the
  actual query order, including numeric names, priorities, and equal-name ties.
- Balance calculation and projections use the previously corrected common order.
  Amount, category, and monthly summaries use exact totals rather than selecting
  a financial first/last row from an unordered collection.
- File encoding and import matching intentionally use locale-independent value
  order, including amounts, category, recurrence, and optional saved balance.
  It provides reproducible files and matching; it does not calculate balances.
  Import balance projections use Item ordering separately.
- Export ambiguity detection and priority preparation retain their existing
  bounded policy. No new persistent ordering field or format version is added.
- Yearly group ranking remains count, first target date, then name. It is a
  recommendation order, not the order of financial transactions. Tag/group
  headings, ledger metadata, year/month selectors, category charts, and route
  matching likewise have their own non-Item semantics.
- Unsorted inventory fetches used only for deletion or membership selection do
  not select a latest balance or financial tie breaker.
- Notification identifier fallback is used for identification, not ordering.
  Encoded identifiers are no longer used as a substitute financial sort key.

## Verification and remaining boundaries

The selected Xcode 27.2 and iOS Simulator 27.2 ran the library's default and
time-zone suites: 897 default tests and 170 time-zone tests passed, with the
one known identity-transition issue retained. After adding the replace-preview
adapter, all eight audit-specific tests passed through the native integration.
Repository formatting/static rules and the Incomes consumer build, including
its Watch target, passed. The full suite used the README's documented
`xcodebuild` fallback for the previously observed native result-reading gap.
Targeted coverage includes duplicate import matching across
contexts and actual replacement, deterministic encoding, notification order and
badges, yearly source entries, and Watch encode/decode/apply/reopen. A legacy
Watch payload without priority still decodes and applies with priority zero.

The previously recorded temporary-to-permanent identity issue remains unresolved;
its [separate reproduction](same-day-item-order.md#deferred-save-time-identity-reproduction)
is retained outside the default acceptance suite. The two-row regression now
checks explicit recalculation after creation is saved. The identity issue can
affect creation, repeated creation, yearly
application, import, and Watch cache reconstruction when every other Item key
ties. The audit does not introduce a cross-store identity/order guarantee.
Watch remains a bounded reconstructed cache: carrying priority does not make its
new native IDs or zero-based cache balances identical to the phone's full ledger.

No physical WatchConnectivity transfer, CloudKit delivery, notification delivery,
or VoiceOver session was performed. Library tests establish payload, planning,
persistence, and selection behavior; consumer builds establish compilation.
