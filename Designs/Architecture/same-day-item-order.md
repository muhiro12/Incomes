# Same-day Item order and running balances

Investigation for [#420](https://github.com/muhiro12/Incomes/issues/420).
The [consumer audit](item-order-consumers.md) records the subsequent review and
corrections across Incomes' features and companion targets.
The reported installed app version and original triggering operation remain
unknown. The cases below use synthetic data in the current shared library.

## Reproduced boundaries

Chronological queries order by date ascending, priority descending, content
ascending, and native persistent identity ascending. Reverse lists invert each
key. The phone's `LedgerItemQuery` displays these query results directly.

Three independent mismatches were reproduced:

1. String `Comparable` used a different order from the query's localized,
   numeric string comparison. With equal date and priority, creating
   `Entry 2` (+1), `Entry 10` (+2), and `Entry 1` (+3) produced this result:

   | Displayed Item | Balance before the fix | Expected balance |
   | --- | ---: | ---: |
   | Entry 1 | 3 | 3 |
   | Entry 2 | 6 | 4 |
   | Entry 10 | 5 | 6 |

   Mixed case and accented names also reproduced the mismatch.
2. For identical names, the calculator compared the debug description of
   `PersistentIdentifier`. That description included a managed-object address;
   it was not the query's native identifier comparison.
3. During creation, even a native identifier comparison can change order when
   a temporary identifier becomes permanent at save. Two same-name Items with
   amounts +1 and +2 can be displayed with balances 3 and 2 after saving,
   instead of 1 and 3. This remains unresolved.

## Implemented scope

- `ItemOrdering` defines the date, priority, localized standard content, and
  native identity descriptors once. Native queries and in-memory Item comparison
  use this definition, reversing every key for reverse order. Calculation consumes
  the chronological query directly without an additional independent sort.
- Balance projection and import review use the same descriptor factory.
  Their planned rows have a typed request-index tie breaker, with no model debug
  descriptions. Newly inserted rows still have the unresolved save-time boundary.
- Export priority preparation uses the same content comparison when deciding
  which otherwise ambiguous rows need a priority step in the exported copy.
- Existing amounts, dates, identities, ownership, and stored priorities remain
  unchanged. Reading or reopening a store does not recalculate saved balances.
  Normal mutations and explicitly requested recalculation retain their existing
  affected-date and ledger boundaries.

Changing the comparator does not repair previously saved inconsistent balances.
The existing explicit recalculation operation can update a selected range using
the corrected order. This investigation does not authorize automatic historical
repair.

## Verification and remaining boundary

`ItemRunningBalanceOrderTests` covers numeric names, mixed case and accents,
saved identity ties after explicit recalculation, amount/name/priority/date
edits, projection minimum balance, SQLite reopening, and updates saved by a
second context. Each assertion checks the actual display query and running
balance for every row. The two-row same-name creation case verifies recovery
after explicit recalculation, preserving the saved identifiers and amounts.
It does not assert that creation itself repairs a save-time identity transition.

`ItemBalanceRecalculationOrderTests` starts with deliberately inconsistent saved
balances and verifies that explicit recalculation repairs each row in the current
query order. Repeating the operation and reading from another context preserve
that result. Amounts, dates, identities, stored priorities, previous-day balances,
and another ledger remain unchanged. A second test changes a name in another
context without recalculation, then verifies that recalculation repairs balances
using the new order. This is a local persistence test, not CloudKit delivery.

The save-time transition from temporary to permanent identity remains separate
from recalculation of saved rows. A durable cross-store ordering key is not
required for the latter repair and is not introduced here. Fixing the creation
boundary needs to preserve the existing mutation and rollback contract; adding
a save before calculation would split its single-save transaction. Cross-store
order preservation is also a separate design decision.

### Deferred save-time identity reproduction

The save-time defect is outside this repair's acceptance criteria. It was
previously recorded as an expected failure in the default suite; that test now
checks the supported recovery operation instead. The defect remains unresolved,
and this change does not claim that immediate post-creation balances are correct
when identifiers change their tie order.

To reproduce separately with a fresh in-memory container:

1. Call `ItemCreationOperations.createAndSaveWithOutcome` twice, with the same
   date, content `Same`, category, and priority zero; use income 1, then income 2,
   outgo zero, and no repeats.
2. Fetch `.items(.all, order: .forward)` before requesting recalculation.
3. Accumulate each fetched row's income minus outgo, and compare that cumulative
   total with its saved balance. A mismatch demonstrates the defect; do not
   assume which income the native identifier will order first.
4. Run `ItemBalanceOperations.recalculateAndSave` from `.distantPast` and repeat
   the comparison. Every balance must now match the current query sequence.

On the investigated Xcode 27.2 / iOS Simulator 27.2 run, the two rows displayed
balances 3 and 2 before recalculation. Different assigned identities may avoid
that particular reproduction. Persisted-identity stability, new ordering keys,
and changes to the single-save creation contract require separate work.

### Earlier verification

On 2026-11-13, the selected Xcode 27.2 toolchain ran 890 default library tests
and 170 time-zone tests on iOS Simulator 27.2. The run succeeded with one known
issue: same-name creation. The repository's formatter and static rules passed.
The `Incomes` consumer scheme also built successfully on the same Simulator.
The native integration could not finish reading the full test result bundle;
the documented `xcodebuild` fallback completed the suite with `SDKROOT` removed
and library-only App Intents metadata extraction disabled.

Native localized comparison may also differ across locales, and native store
identities are not a cross-device ordering contract. Real CloudKit delivery,
different-locale clients, and the originally reported installed build have not
been qualified by these local tests. External-update refresh and historical
reconciliation remain distinct from this reproduced local ordering defect;
do not infer a CloudKit diagnosis or data loss from it.
