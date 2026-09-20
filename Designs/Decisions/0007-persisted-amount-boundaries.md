# ADR 0007: Persisted Amount Boundaries

- Date: 2026-09-20
- Status: Accepted

## Context

Income and outgo are stored as `Decimal`. Two limits were never written down,
so amount handling could change a value without telling anyone:

- Amount text was parsed through `NumberFormatter`, which converts long input
  through a binary double. `12345678901234567890` was silently stored as
  `12345678901234570000`, and text long enough to overflow the parser produced a
  non-finite `Decimal` that validation accepted.
- The persistent store keeps fewer digits than `Decimal` itself. Saving items to
  a SwiftData store on disk, reopening it, and comparing the values shows that
  amounts with up to 15 significant digits come back unchanged, while longer
  values come back rounded.

## Decision

- Negative income and negative outgo are valid. There is no non-negative rule,
  and zero stays a normal value.
- An amount is supported when it is finite and has at most **15 significant
  digits**. The limit is a property of the store, not of display formatting or a
  character count, so an amount may still be short or long in the text field.
- Amount text is parsed exactly. Locale grouping and decimal separators are
  preserved, and a value that cannot be kept exactly is rejected with a specific
  message instead of being rounded into the store.
- Derived amounts, such as the yearly-duplication average, are rounded to the
  supported precision in the library at the moment they are calculated. Entered
  amounts are never rounded or clamped.
- A running balance that leaves the representable range is refused before any
  balance is written, so a non-finite value cannot be persisted.

## Consequences

- `AmountPrecision` owns the limit, and every adapter reaches it through the
  shared parsing and validation contracts rather than repeating a rule.
- Records created before this decision keep their stored values. They remain
  readable, exportable, and editable, because a value already in the store is
  within the supported precision by definition.
- Raising the limit later requires new persistence evidence that the store
  keeps the additional digits through a save and reopen.
