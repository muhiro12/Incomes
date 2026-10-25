# Format 1 / schema 2.0.0 fixtures

These synthetic files define the 6.1 interchange baseline. `Incomes.incomes`
covers exact amounts, dates, recurrence, categories, and saved balances in the
default ledger. `Ledgers.incomes` also covers additional and empty ledgers.
The fixture tests verify their values and canonical writer bytes.

Their record values originate from the development V2 and released 6.0 V3
fixtures. The headers now declare `fileType`, format 1, and SwiftData schema
2.0.0; ledger ownership is explicit in both. After publication, do not regenerate
these fixtures with a newer encoder or change the pair's historical meaning.

`../Incomes-6.0.incomes` preserves the original synthetic 6.0 bytes unchanged.
Its payload matches `Ledgers.incomes` after header adaptation. Tests verify
value preservation, re-export to the current canonical bytes, strict header
recognition, and the normal payload validation rules. Development V2 remains
unsupported; no separate V2/V3 payload reader is retained.
