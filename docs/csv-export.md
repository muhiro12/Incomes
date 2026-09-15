# CSV export

Settings > Manage items > Export CSV exports saved Items for spreadsheet use.
The initial dates cover the earliest through the latest saved Item, including
future scheduled Items. Both selected dates are inclusive. The screen shows
selected and total Item counts, and All dates resets the range. With no matching
Items, export is disabled.

Selection uses the displayed calendar days, consistent with Incomes' stored UTC
day convention. It does not reinterpret the stored day as a local instant.
Records are captured when Export CSV is pressed; later model changes do not
modify that file. Export never changes Items, tags, balances, or notifications.

## File representation

The file uses UTF-8 with a byte-order mark, comma separators, CRLF record endings,
and English column identifiers. Every data field is quoted; embedded quotes are
doubled. Embedded newlines remain inside their quoted field.

| Column | Meaning |
| --- | --- |
| `date` | Stored calendar day as Gregorian `yyyy-MM-dd`, without a time zone. |
| `content` | Item description. |
| `income` | Exact stored Decimal income; decimal point, no grouping. |
| `outgo` | Exact stored Decimal expense; decimal point, no grouping. |
| `balance` | Stored running balance, including the effect of Items outside the selected range. |
| `currency` | Current app currency setting, or system currency when using System; not a historical per-Item currency. |
| `category` | Stored category name, or empty when absent. |
| `priority` | Stored display priority. |
| `repeat_id` | Existing repeat-series identifier; not a rule for generating new occurrences. |

Rows follow chronological Item order. Only existing saved occurrences are
exported. Derived year/month/content tags are represented by their underlying
fields; debug tags and standalone unused tags are omitted.

User text whose first non-whitespace character is `=`, `+`, `-`, or `@`, or that
starts with a tab/newline, receives a leading apostrophe to prevent ordinary
spreadsheet formula interpretation. This intentionally changes the exported text
representation; it does not alter the stored value. Avoid removing that prefix
or enabling formula interpretation when importing untrusted text.

## Scope

CSV is a readable spreadsheet export, not a lossless backup. It cannot restore
SwiftData identities, all tag relationships, or a database. Files are written
only to a destination selected in the system exporter. Cancelling that dialog
does not save or modify app records. The destination provider controls the
exported file's storage and sharing.
