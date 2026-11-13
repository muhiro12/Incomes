# Same-day Item order and running balances

Investigation for [#420](https://github.com/muhiro12/Incomes/issues/420).
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

- Calculation consumes the chronological query directly. In-memory Item
  comparison uses the query's localized standard content comparison and native
  identifier comparison.
- Balance projection and import review use those same comparison semantics.
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

## Verification and remaining decision

`ItemRunningBalanceOrderTests` covers numeric names, mixed case and accents,
saved identity ties after explicit recalculation, amount/name/priority/date
edits, projection minimum balance, SQLite reopening, and updates saved by a
second context. Each assertion checks the actual display query and running
balance for every row. A separate `withKnownIssue` test retains the unresolved
same-name creation reproduction; an expected failure is not a completed fix.

A durable tie breaker needs a separate design covering existing records,
new records before their first save, CloudKit, repeat-series identity, and
backup/restore. Adding a save before balance calculation would split the
existing single-save mutation and rollback contract, so it is not used here.

On 2026-11-13, the selected Xcode 27.2 toolchain ran 888 default library tests
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
