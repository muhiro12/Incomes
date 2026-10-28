# Item template exchange

Item input assistance offers two paths into the existing editable form:

- **Extract from Text** uses the existing on-device Foundation Models adapter
  to interpret prose, including OCR text. Its availability, cancellation, and
  stale-result checks remain independent of template exchange.
- **Read Template** reads explicit fields without inference. It is available
  on iOS 18 and later and never falls back automatically to a language model.

Both paths leave saving to the ordinary form action and canonical creation
workflow. Template reading is available for new Items only. Exporting a saved
Item creates text that can later prefill another new Item; it cannot identify,
update, or merge the original record.

## Version 1 contract

The identifier is `# Incomes Item Template`, followed immediately by
`Template-Version: 1`. Headings and metadata use these stable English spellings
in every app language. This version is independent of SwiftData and the
`.incomes` backup format. Future changes must explicitly retain a reader or
document the unsupported version; existing text is never silently relabeled.

```markdown
# Incomes Item Template
Template-Version: 1

## Date
- 2026-10-28

## Content
- Lunch
  Paid at the café

## Income
- 0

## Outgo
- 1234.56

## Category
- Food

## Priority
- 0

## Currency
- JPY
```

All seven sections are required exactly once, in any order. Each value starts
with exactly `- ` after its heading. Only Content and Category allow multiline
values: each continuation starts with two spaces, which are removed by the
reader. A blank continuation is two spaces on a line. Additional indentation,
literal Markdown punctuation, and trailing spaces in values are preserved.
Unindented empty lines separate sections and do not add value content.
There is no inline Markdown unescaping, HTML rendering, or resource loading.

One optional outer code fence is accepted, labeled `markdown` or unlabeled.
Surrounding prose, other fences, unknown headings, additional bullets, duplicate
sections, and unsupported versions are errors. CRLF document line endings are
accepted and normalized to LF. Saved text containing lone carriage returns is
outside the export subset. Limits are 16,384 UTF-8 bytes and 512 LF-delimited
lines, including the wrapper; export enforces the same limits.

## Field meaning

- Date is an actual Gregorian `yyyy-MM-dd` day. It is converted between the
  stored UTC day and the form's local calendar day, using the existing Item
  convention. Missing dates do not inherit today's date or an existing draft.
- Income and Outgo are both required plain exact decimal strings: ASCII digits,
  an optional leading minus sign, and an optional period fraction. No grouping,
  exponent, currency symbol, or inferred amount is accepted. The existing store
  precision rules apply. Zero is explicit; blank or unknown is an error.
- Content must contain non-whitespace text. Localized and multiline text is
  retained literally, including text that resembles instructions or links.
- Category may be explicitly blank for uncategorized. Existing uncategorized
  aliases follow the app's normal semantics. Unknown named categories require
  confirmation before the draft is applied; no Tag is created by reading.
- Priority is a canonical signed integer accepted by the existing form. Export
  retains older stored priorities outside the standard editor's 0–10 range.
- Currency must match the explicit three-letter uppercase app preference.
  An unset preference requires a currency choice in Settings before exchange.
  Import never converts amounts or changes the currency setting.

The ledger is selected in the app and captured with the draft. Text cannot
choose or create a ledger. Saved balances, recurrence, internal identities,
CloudKit metadata, and attachments are omitted. This is a supported-field
exchange, not a lossless backup. Normal creation still recalculates balances and
performs its existing entitlement and update checks.

## Interaction and recovery

The template screen displays the prompt and blank template with explicit copy
actions. People may fill it themselves or invoke an external tool. Pasted text
is retained when validation fails. A successful read presents a preview before
applying it to the existing form. Back, Cancel, and dismissal leave the form and
store unchanged. Source, currency, or draft changes invalidate the preview.
Applying a template leaves repetition disabled for the new draft; people can
subsequently enable it in the ordinary form.

The preview discloses its destination ledger, currency, and any new category.
The final form remains editable, with the ordinary Create action required to
persist. Reopening input assistance retains the source text for that form.
Export displays selectable text, Copy, and the native share sheet, with the
omissions visible before sharing. Neither path automatically sends data.

## Parser choice

[Swift Markdown](https://github.com/swiftlang/swift-markdown) provides a full
Markdown syntax tree and remains appropriate if richer Markdown is adopted.
Version 1 intentionally uses literal values and a seven-section line grammar.
A bounded Foundation/standard-library reader preserves exact whitespace and
rejects unsupported syntax directly, without adding a Markdown dialect or
dependency. Rendering or accepting arbitrary Markdown is not part of this
contract. Its behavior is covered by shared-library tests.

Related: [#414](https://github.com/muhiro12/Incomes/issues/414),
[backup and restore](data-import-export.md).
