# Data import and export

The ownership-aware file format is 3.0.0. Legacy 2.0.0 files remain readable
and always describe the default book. File versions are independent of the
SwiftData schema: adding book ownership to the file does not add stored model
attributes.

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

- Every item's date, content, income, outgo, category, priority, repeat ID, and ledger reference.
- Additional-ledger names and file references, including empty ledgers.
- The item's running balance, for readers only.
- Settings that describe the records, currently the currency code.

Ledger references are opaque digests derived from native Tag identities. They
remain stable across a rename in the source store without exposing the encoded
SwiftData identifier or store payload. Import first recognizes an existing local
reference; otherwise it compares a uniquely named destination ledger. Ambiguous
names stop the import for explicit user resolution. A newly restored ledger gets
a new native destination Tag identity.

The file never contains `PersistentIdentifier` values, debug tags, subscription
or iCloud state, logs, or device information.

## File format

The file is UTF-8 JSON with sorted keys and indentation, so the same records
always produce the same bytes. The file extension is `incomes`, and its type
`com.muhiro12.incomes.data` conforms to `public.json`.

Reading and writing share a 32 MiB limit. Export refuses a larger payload so it
cannot produce a file this version cannot restore. The URL reader bounds the
bytes loaded even if the file size changes after selection.

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
      "ledgerID": "default",
      "outgo": "80000",
      "priority": 0,
      "repeatID": "3F2504E0-4F89-41D3-9A0C-0305E82C3301"
    }
  ],
  "ledgers": [],
  "schemaVersion": "3.0.0",
  "selection": {
    "filters": [],
    "ledgerIDs": ["default"]
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
and `settings` is optional. Planned sections include category attributes
and notification settings. V3 requires the ledger metadata section `ledgers`.

- A section or field that a reader can ignore without changing the meaning of
  the remaining data may be added within the same schema version. Readers
  ignore unknown keys.
- Data whose omission would change meaning, such as ledger ownership, requires
  a new schema version.

`selection.ledgerIDs` explicitly lists covered owners in V3. An empty
`selection.filters` list means all Items within those owners. Replacing this
selection cannot erase another owner. The current full export includes the
default book even when it is empty. Planned filter kinds include a date range
and categories. V2 files retain their original optional selection shape and
resolve only to the default ledger.

V3 refuses duplicate book IDs. Additional-book names are metadata, not identity;
same-name books stay distinct. Merge retains existing names unless explicitly
changed in review. See [Independent ledgers](independent-ledgers.md).

- Filters are must-understand. A reader rejects a file containing a filter kind
  it does not know, instead of mistaking a partial file for a complete one.
  Therefore a new filter kind can be added within the same schema version.
- The selection also defines the scope of a replacement import: replacing with
  a file covering 2026 replaces only 2026 records. A file without a
  `selection` key covers all records.

## Versioning

File versions describe portable financial meaning independently of the
[SwiftData storage history](swiftdata-schema-evolution.md).

- Export writes the latest file version. Ownership-aware V3 is required even
  though its Items and Tags retain storage schema V2.
- Each file version has a frozen payload type and a committed decoding fixture.
  A released payload must not be edited in place.
- Import converts supported older payloads into the current representation and
  rejects newer versions. It never infers an additional owner for a V2 Item.
- A stored-model change requires reviewing the file contract; a version increase
  is necessary when omitting the new data would change its financial meaning.

The first file version is `2.0.0`. Files were never written for earlier schemas.

## Import flow

1. Read the file, check its size limit, format, and version, then validate every
   item before anything is written.
2. Compare the file with the store and show the difference.
3. Apply the chosen policy only after explicit confirmation. The operation
   inserts, deletes, removes unused tags, and recalculates balances. The
   app calls `ItemImportOperations.applyAndSaveWithOutcome`, which saves once
   in an isolated context before the mutation workflow runs follow-ups.

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
- **Replace** makes the item values inside the file's selection equal to the file.
  The preview lists the items that will be removed and added. Matched items
  stay in place, so their identifiers, links, and series are kept.
- **Merge** never removes a record unless the person asks for it:
  - Matched items are left unchanged.
  - Each change group keeps the current items by default. The person can instead
    use the file's items, or keep both.
  - Additions are inserted by default and can be excluded one by one.
  - Store-only items are kept.

Newly inserted items keep the file's repeat IDs. Matched items keep the store's
current series, even when the file records different repeat IDs. Import does
not reconcile those identities, so a partial restore into an existing store
does not guarantee reconstruction of a whole exported series. Import into an
empty store preserves the file's complete series membership.
Balances are validated for the final result before any record changes.

When the file's currency differs from the current setting, the confirmation
offers to adopt it. The option is on by default for an empty store and off
otherwise.

### Store changes after review

The review captures every store item's identity and values, including matched
items and recurrence. The operation rechecks this snapshot immediately before
applying it. A changed store or pending edits in the review context refuse the
import with `storeChangedSinceReview`, and the preview must be shown again.

The import owns an isolated context with autosave disabled. It saves once after
validation; a failure rolls back only its own changes. Other pending edits are
never saved or discarded by import. Created identifiers are returned only after
the save succeeds, and notifications, widgets, and Watch refresh afterward.
An adopted currency is set after a successful save and before those refreshes.
A currency-setting change during review requires a fresh adoption choice.
Validation errors reach the screen unchanged so a stale review is refreshed;
post-save follow-up failures are logged without reporting an unsaved import.

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
