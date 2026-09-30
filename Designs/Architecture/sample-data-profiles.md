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

Seeding writes into the context it receives. Only explicit actions seed the
user's store:

- SwiftUI previews use `IncomesSampleData.makePreviewContext(profile:)`, which
  seeds an in-memory, CloudKit-disabled container. The Watch preview wrapper
  also uses an in-memory container.
- Tests seed in-memory contexts.
- Debug "Add Sample Data" requires the Debug option and a confirmation, then
  adds the chosen profile to the user's store.
- UI smoke seeding runs only in Debug builds, only with the
  `--incomes-ui-smoke-seed-if-empty` launch argument, and only when the store
  is empty.

Settings removes seeded data with the debug-data delete action. Watch Debug
has the same action.

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
