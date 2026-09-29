# Incomes file fixture — 2.0.0

- Freezes the first Incomes file version, written by schema 2.0.0. Every later
  Incomes version must keep reading this file with the same values.
- Produced with Foundation's `JSONEncoder` using the payload keys, sorted keys,
  indentation, and unescaped slashes of `IncomesFileV2`, then committed as the
  version's reference bytes.
- Contents are synthetic: a three-month repeat series, a quoted multiline
  description, an empty category, negative amounts, a non-ASCII category, and
  running balances in store order.
- Do not regenerate this file. A format change needs a new schema version and a
  new fixture directory.
