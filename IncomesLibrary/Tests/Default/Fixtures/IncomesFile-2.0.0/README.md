# Incomes file fixture — 2.0.0

- Records the earlier development payload 2.0.0 and its scalar values. File
  import and export were not shipped in 5.12; the public 6.0 writer uses 3.0.0.
- Produced with Foundation's `JSONEncoder` using the payload keys, sorted keys,
  indentation, and unescaped slashes of `IncomesFileV2`, then committed as the
  version's reference bytes.
- Contents are synthetic: a three-month repeat series, a quoted multiline
  description, an empty category, negative amounts, a non-ASCII category, and
  running balances in store order.
- The format identifier was corrected to `com.muhiro12.Incomes.data` before the
  first public release. No alternate namespace is accepted. Keep scalar values
  unchanged; payload changes need a new version and fixture directory.
