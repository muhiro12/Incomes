# Data import and export

Settings > Manage items > Export data writes every saved item to one Incomes
file. Settings > Manage items > Import data reads such a file and, after a
review, restores or merges its items. The file is the only portable format:
it restores data without iCloud and can be kept outside the device.

The architecture, versioning rules, and extension rules are described in
[Data import and export](../Designs/Architecture/data-import-export.md).

## Export

The screen shows the number of items and the period they cover. Export is
disabled when there are no items. Records are captured when Export is pressed;
later changes do not modify that file, and exporting never changes items, tags,
balances, or notifications. The file is written only to a destination chosen in
the system exporter; cancelling saves nothing.

The default file name is `Incomes yyyy-MM-dd.incomes`. The file contains
financial records, so the screen asks the person to keep it private.

This version supports files up to 32 MiB. A larger export is refused with an
error rather than writing a file the app cannot reopen; existing data is kept.

## Import

The person chooses a file in the system picker. Incomes reads and validates the
whole file before showing anything, then compares it with the saved items.

- A file equal to the saved items reports that there is nothing to import.
- With no saved items and iCloud sync off, every item is imported directly.
- Otherwise the person chooses **Merge** or **Replace**. The screen recommends
  exporting the current data first and offers that export in place.
  - Merge keeps every saved item. Items only in the file are added and can be
    excluded one by one. Saved and file items that share a day and description
    but differ are shown together, and the person keeps the current items,
    uses the file's items, or keeps both.
  - Replace makes the saved items equal to the file after a confirmation.
    Items equal on both sides stay in place.
- The summary shows how many items are added, removed, unchanged, and kept.
- When the file's currency differs from the current setting, the person can
  adopt it. The option is on by default only for an empty store.
- With iCloud sync on, a warning explains that the import also changes other
  devices, and that changes not yet received from them may duplicate or
  reappear.

When import adds or removes items, all balances are recalculated. If saved items
have changed while the person
is reviewing, the import stops and the review is shown again. A failed import
leaves the saved items unchanged.

New items keep the file's repeat-series identifiers. Equal items already in the
store keep their current series and links. Import does not combine different
series identities; restoring into an empty store preserves the exported series.

## Errors

Import refuses, without changing data, a file that:

- is larger than 32 MiB;
- is not an Incomes file, or is damaged;
- was written by a newer version of Incomes, or covers a selection this
  version cannot interpret;
- contains an invalid date, amount, or repeat identifier; or
- would produce a balance the store cannot keep exactly.

## File representation

The file is UTF-8 JSON with sorted keys, and its type
`com.muhiro12.incomes.data` conforms to `public.json`.

| Key | Meaning |
| --- | --- |
| `format` | Always `com.muhiro12.incomes.data`. |
| `schemaVersion` | Storage schema that wrote the file, such as `2.0.0`. |
| `exportedAt` | ISO 8601 UTC time of the export. |
| `selection` | Covered records; `{"filters": []}` means every record. |
| `settings.currencyCode` | Currency setting at export time, when set. |
| `items` | Items in chronological order. |

Each item has these keys:

| Key | Meaning |
| --- | --- |
| `date` | Stored calendar day as Gregorian `yyyy-MM-dd`, without a time zone. |
| `content` | Item description. |
| `income`, `outgo` | Exact decimal strings; period separator, no grouping. |
| `category` | Stored category name, or empty when absent. |
| `priority` | Display priority among items on the same day. |
| `repeatID` | Repeat-series identifier, kept on import. |
| `balance` | Optional running balance for readers; never imported. |

Derived year, month, and description tags are represented by their underlying
fields. Debug tags, unused tags, identifiers local to the store, subscription
and iCloud settings, and diagnostics are not written.
