# Data import and export

## Purpose

Export and import move a person's financial records in and out of Incomes as
one portable file. The primary use is recovery: restoring after a mistake, a
failed device, or a device change, without depending on iCloud. Later uses,
such as handing a ledger to another person, giving records to an AI assistant,
or exporting a selected period or category, must fit the same file without a
second format.

Export and import use one format in both directions, the Incomes file. There is
no separate spreadsheet export.

## Relationship to other mechanisms

| Mechanism | Why it is not a substitute |
| --- | --- |
| iCloud sync | Propagates deletions and mistakes to every device. |
| Device backup | Restores a whole device, not one app at a chosen time. |
| Store relocation and schema migration | Move or upgrade the live store. |

Relocation and migration recovery remain the responsibility of the persistence
layer, including any pre-migration safety copy of the store. An Incomes file is
a user-held record, not a copy of the SQLite store.

## Stored data and the file

The store contains `Item` and `Tag` records. Year, year-month, and content tags
are derived from item fields, so the file omits them. A category tag carries
meaning, so each item records its category name. The file contains:

- Every item's date, content, income, outgo, category, priority, and repeat ID.
- The item's running balance, for readers only.
- Settings that describe the records, currently the currency code.

The file never contains `PersistentIdentifier` values, debug tags, subscription
or iCloud state, logs, or device information.

## File format

The file is UTF-8 JSON with sorted keys and indentation, so the same records
always produce the same bytes. The file extension is `incomes`, and its type
`com.muhiro12.incomes.data` conforms to `public.json`.

```json
{
  "exportedAt": "2026-09-29T03:04:05Z",
  "format": "com.muhiro12.incomes.data",
  "items": [
    {
      "balance": "120000",
      "category": "Housing",
      "content": "Rent",
      "date": "2026-03-08",
      "income": "0",
      "outgo": "80000",
      "priority": 0,
      "repeatID": "3F2504E0-4F89-41D3-9A0C-0305E82C3301"
    }
  ],
  "schemaVersion": "2.0.0",
  "selection": {
    "filters": []
  },
  "settings": {
    "currencyCode": "JPY"
  }
}
```

- `date` is the stored calendar day as Gregorian `yyyy-MM-dd`, without a time
  zone, matching the store's UTC day convention.
- Amounts are exact decimal strings with a period separator and no grouping.
  Numbers are never written as JSON numbers, which would pass through binary
  floating point.
- An amount must fit the store's precision contract from ADR 0007.
- `balance` is optional and informative. Import always recalculates balances
  from the imported items and never trusts this value.
- `priority` is an integer and `repeatID` is a UUID string.

## Extension rules

The file can grow along two axes without breaking older readers.

Sections describe which kinds of data the file contains. `items` is required
and `settings` is optional. Planned sections include category attributes,
notification settings, and ledgers.

- A section or field that a reader can ignore without changing the meaning of
  the remaining data may be added within the same schema version. Readers
  ignore unknown keys.
- Data whose omission would change meaning, such as ledger ownership, requires
  a new schema version.

`selection.filters` describes which records the file covers. An empty list
means all records, which is the only selection written today. Planned filter
kinds are a date range, categories, and a ledger.

- Filters are must-understand. A reader rejects a file containing a filter kind
  it does not know, instead of mistaking a partial file for a complete one.
  Therefore a new filter kind can be added within the same schema version.
- The selection also defines the scope of a replacement import: replacing with
  a file covering 2026 replaces only 2026 records. A file without a
  `selection` key covers all records.

## Versioning

The file format follows the SwiftData schema history in
[SwiftData schema evolution](swiftdata-schema-evolution.md).

- `schemaVersion` records the `versionIdentifier` of the schema that wrote the
  file. Export always writes the current schema version.
- Each schema version that can appear in a file has a frozen payload type, like
  each frozen `IncomesSchemaVn`. A payload type is never edited after release.
- Import converts an older payload forward into the current representation.
  It rejects a newer version and asks the person to update Incomes.
- Adding a storage schema version requires adding the matching file version.
  A test compares the current file version with the last schema in
  `IncomesSchemaMigrationPlan`, and a committed fixture for each file version
  must keep decoding.

The first file version is `2.0.0`. Files were never written for earlier schemas.

## Import flow

1. Read the file, check its size limit, format, and version, then validate every
   item before anything is written.
2. Compare the file with the store and show the difference.
3. Apply the chosen policy only after explicit confirmation. The operation
   inserts, deletes, removes unused tags, and recalculates balances. The
   caller's mutation workflow saves once.

Before a policy that changes existing records, the confirmation recommends
exporting the current data first and offers that export directly.

### Difference

The comparison is deterministic: the same file and store always produce the
same classification, independent of record order.

- The comparison covers the store items inside the file's selection.
- The match key contains `date`, `content`, `income`, `outgo`, `category`, and
  `priority`. `repeatID` is excluded because every edit assigns a new one;
  `balance` is excluded because it is derived.
- Items are matched by counting equal keys on both sides. If the file holds
  three equal items and the store holds two, two match and one remains on the
  file side. Equal items are interchangeable, so the choice of which ones
  matched cannot change the result.

After matching, the remaining items are classified:

| Class | Meaning |
| --- | --- |
| Matched | Equal on both sides. |
| Change group | Unmatched file and store items sharing `date` and `content`. |
| Addition | An unmatched file item outside every change group. |
| Store only | An unmatched store item outside every change group. |

A change group is resolved as a whole. Items inside a group are never paired
one by one, so several similar items on the same day do not create an arbitrary
pairing.

Incomes cannot prove that two different records are the same item: the
persistent identifier is local to one store, and the repeat ID changes on edit.
Equal records are safe to treat as the same, while every other relationship is
shown to the person. Shortly after an export, almost every record matches, so
the remaining decisions stay small.

### Policies

- An empty store without iCloud sync imports every item directly.
- **Replace** makes the store inside the file's selection equal to the file.
  The preview lists the items that will be removed and added. Matched items
  stay in place, so their identifiers, links, and series are kept.
- **Merge** never removes a record unless the person asks for it:
  - Matched items are left unchanged.
  - Each change group keeps the current items by default. The person can instead
    use the file's items, or keep both.
  - Additions are inserted by default and can be excluded one by one.
  - Store-only items are kept.

Imported items keep their repeat IDs, so series membership survives a restore.
Balances are validated for the final result before any record changes.

When the file's currency differs from the current setting, the confirmation
offers to adopt it. The option is on by default for an empty store and off
otherwise.

### Store changes after review

The operation recalculates the difference immediately before applying it. If
the store no longer produces the difference the person reviewed, the import is
refused with `storeChangedSinceReview` and the preview must be shown again.

### iCloud sync

Import remains available while iCloud sync is on, with a warning that the change
reaches every synced device. A device cannot know whether its local store has
received every cloud change, so an apparently empty store may not be empty:

- With sync on, the empty-store shortcut is never used; the person chooses
  replace or merge.
- Records that arrive from iCloud after an import can still duplicate or
  reappear. This risk can be reduced by observing sync activity, but not
  removed.

## Timing

- Creation: the person exports manually from Settings.
- Receiving: the person imports from Settings by choosing a file.
- Planned: open-in from Files or AirDrop, an import offer on an empty first
  launch, and recovery from the startup failure screen.

## Future work

- Stable item identifiers, considered together with the ledger schema change,
  would let a change group be decided by identity instead of by date and
  content. The classification and policies would keep their shape.
- Filters, category and ledger sections, and notification settings follow the
  extension rules above.
- Sharing with other people and AI assistants needs privacy copy and a public
  format specification.
