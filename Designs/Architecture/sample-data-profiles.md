# Sample Data Profiles

## Purpose

Previews, Debug seeding, UI smoke runs, screenshots, and tests draw their data
from one fixture layer: the named profiles in `SampleDataOperations.Profile`.
A profile names a dataset once, so each surface picks a profile instead of
building its own look-alike data.

Incomes ships no product-facing sample or tutorial records. Every profile is a
developer fixture, and every item it seeds carries the debug "Sample Data" tag
so `SampleDataOperations.deleteDebugData(context:)` can remove it again.

## Profiles

- `minimal`: three items over the two days before the base date. Watch
  previews and maintenance tests use it.
- `standard`: nine monthly templates for 24 months from the start of the base
  year, after an opening payday, for 217 items. App previews, Debug "Prepare",
  UI smoke seeding, and screenshots use it.
- `largeLedger`: the standard templates for 120 months, ending with the
  standard two years, for 1,081 items. Debug "Prepare large ledger" uses it for
  low-priority performance checks.
- `duplicateTags`: the standard ledger with two Credit items re-tagged by
  duplicates of every tag type. Duplicate-tag previews and Debug "Prepare
  duplicate tags" use it.
- `largeAmounts`: one item per month of the base year, with a balance from
  about -1.75M to 1.25M. Chart axis previews use it.
- `inexactTotals`: two items of 10^40 and 1 in one category, with balances left
  uncalculated. The category chart preview for inexact totals uses it.

`largeLedger` and `duplicateTags` compose the standard ledger. The edge-case
profiles, `duplicateTags`, `largeAmounts`, and `inexactTotals`, each reproduce
one specific state and stay separate from the ordinary datasets.

`duplicateTags` changes only the items it seeds, so seeding it into a store
that already holds records leaves those records untouched.

## Determinism

- `baseDate` anchors every dated profile. Dates use `Calendar.current`, so the
  device time zone applies. Tests pass a fixed base date, and the time-zone
  test target runs them under several time zones.
- Ledger templates define amounts in USD and scale them to the magnitude of
  the `locale` currency through `LocaleAmountConverter`. Pass a locale for a
  fixed result. Edge-case profiles use fixed amounts in every locale.
- Content and category names come from `SampleData.xcstrings` in the app's
  language.
- Persistent identifiers and repeat IDs are generated on every seed. Profiles
  do not promise stable identifiers; compare seeded data by date, content, and
  amount.

## Store Safety

Seeding writes into the context it receives. Store selection keeps development
records separate from released financial records:

- Normal DEBUG startup opens `Incomes-Development.sqlite` in the App Group,
  with CloudKit disabled, and seeds the standard profile only when creating that
  database file. No launch arguments are needed. DEBUG widgets read this same
  development file; App Intents use the host's development container. Watch
  continues to receive phone snapshots in its isolated in-memory store.
- Release continues to use `Incomes.sqlite` and its existing iCloud preference.
  DEBUG startup never relocates, copies, or opens the released or legacy store.
  Existing development records previously stored there remain in that file.
- SwiftUI previews use `IncomesSampleData.makePreviewContext(profile:)`, which
  seeds an in-memory, CloudKit-disabled container. Watch previews do likewise.
- Tests use isolated contexts or temporary store directories.
- Diagnostics "Add Sample Data" is compiled only in DEBUG builds. After
  confirmation, it adds the chosen profile only when the development store has
  no items. The operation validates the context's actual store URL, writable
  persistent configuration, and absence of a CloudKit container before mutation.
  Other stores and populated stores are rejected without changing their records.
  This action works without restarting after disabling automatic seeding or
  deleting samples, independently of the initial-seeding setting.
- The explicit `--incomes-ui-smoke-seed-if-empty` argument remains available for
  smoke workflows. Unlike automatic initialization, it intentionally refills an
  empty development store when requested. Screenshot mode keeps its independent
  in-memory fixtures.

The database file itself records initialization, independently of item count.
Subsequent launches preserve developer edits and intentional empty states. A
failed initial seed surfaces through startup recovery; retry opens the existing
store without adding another dataset. Use the explicit Debug action if samples
are needed after recovery. An unreadable store fails instead of being replaced.

To disable automatic seeding, set `automaticallySeedsSampleData` to `false` in
`IncomesStartupDebugOptions.swift` and rebuild. This changes only initialization;
it never deletes existing records. For an empty-state check on an existing
installation, separately use Settings maintenance to remove the records, without
the explicit smoke-seeding argument. Re-enabling automatic seeding still leaves
that existing empty database empty. Only removing the development database file
(or using a fresh installation) makes it new again.

DEBUG ignores the saved iCloud preference and omits the iCloud toggle and restart
notice. The former `--incomes-ui-smoke-icloud-on` argument no longer enables
CloudKit in DEBUG. Use a deliberately prepared Release environment for CloudKit
integration checks. This does not change the saved Release sync preference.

Settings removes seeded data with the debug-data delete action, including in
Release builds so previously added samples can still be removed. Watch Debug
has the same action in DEBUG builds.

## Surfaces

- App previews: `IncomesSampleData` (standard) is the default. Edge-case
  previews use `IncomesDuplicateTagSampleData`, `IncomesLargeAmountSampleData`,
  or `IncomesInexactTotalSampleData`. Add a preview modifier only when a
  preview needs another profile.
- Widget previews use literal timeline entries because widgets render entries,
  not stores.
- UI smoke runs and screenshot capture launch a Debug build with
  `--incomes-ui-smoke-seed-if-empty` on a Simulator whose Incomes store is
  empty, so every capture shows the standard ledger in the Simulator's language
  and currency without manual data entry.
- Library tests call `SampleDataOperations.seed` when they need a realistic
  ledger. Tests of a single invariant keep building their own minimal items.
  Persisted-format fixtures under `IncomesLibrary/Tests/Default/Fixtures` stay
  separate because they pin released store and file formats.

## Adding a Profile

1. Add a `SampleDataOperations.Profile` case with a one-line purpose.
2. Compose the standard ledger when the new data is a variation of it.
3. Tag every seeded item with the debug "Sample Data" tag.
4. Cover the profile in `SampleDataOperationsTests`.
5. Add it to the table above and to any surface that uses it.

## Diagnostic Boundaries

Settings exposes Diagnostics in both DEBUG and Release. The existing Debug route
opens this same visible screen. The iOS console can inspect current and previous
logs, adjust capture level, and copy or export logs explicitly. Clearing logs
requires confirmation and does not clear financial records. Release starts with
warning/error capture; changing diagnostic visibility does not change capture
level. Users should inspect logs before sharing them.

The ordinary Settings entry is also the intended entry in TestFlight and App
Store builds. Removing the former `Enable Debug` secret command was deliberate:
the owner needs occasional inspection in the distributed app, and a discoverable
entry avoids relying on hidden functionality that needs separate App Review
consideration. Do not restore a secret command, gesture, or saved mode as an
unlock requirement. Individual development tools remain build-gated; the
item-detail preference only controls optional diagnostic values. See the
[owner clarification](https://github.com/muhiro12/Incomes/issues/417#issuecomment-6465664421).

The data-inspection paths are read-only: all items and tags lead to diagnostic
values without edit, duplicate, delete, or recalculation controls. The optional
item-diagnostics toggle uses the existing preference and adds raw values to the
ordinary item detail screen; launching the app does not override that choice.
Watch Diagnostics only browses its received item/tag snapshot in Release.

Sample insertion, TipKit test controls, ad/subscription test placements, and the
experimental natural-language-search UI remain behind `#if DEBUG`. Diagnostics
uses the Settings entry without an item-form activation command. A persisted
diagnostic preference cannot enable development controls in Release. Screenshot
fixtures that simulate subscription state remain DEBUG-only and use isolated
stores and preferences.

Release retains the explicit Settings maintenance operation for removing samples
added by older versions. Diagnostic visibility does not grant Premium access;
purchase status and normal financial mutations retain their existing checks.

Technical safety and App Review disclosure are separate requirements. The visible
Settings entry explains the support purpose of these tools rather than relying
on a secret gesture. Review notes for a release exposing Diagnostics should
identify Settings > Advanced > Diagnostics, describe local log export and
read-only inspection, and distinguish these from excluded development controls.
This source change does not update App Store Connect or establish review approval.
