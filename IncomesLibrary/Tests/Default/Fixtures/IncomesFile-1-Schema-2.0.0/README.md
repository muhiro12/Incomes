# Format 1 / schema 2.0.0 fixtures

These synthetic files define the 6.1 interchange baseline. `Incomes.incomes`
covers exact amounts, dates, recurrence, categories, and saved balances in the
default ledger. `Ledgers.incomes` also covers additional and empty ledgers.
The fixture tests verify their values and canonical writer bytes.

Their record values originate from the retired development V2 and 6.0 V3
fixtures. The headers now declare `fileType`, format 1, and SwiftData schema
2.0.0; ledger ownership is explicit in both. They are new fixtures, not evidence
that the previous files are readable. After publication, do not regenerate
them with a newer encoder or change the pair's historical meaning.

`../UnsupportedIncomes-6.0.incomes` preserves the original synthetic 6.0 bytes
solely to verify rejection. No compatibility reader is retained.
