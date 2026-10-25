# Data import and export

The file declares the writing SwiftData schema in `schemaVersion` and its
container/encoding revision in `formatVersion`. The current supported pair is
format 1 with schema 2.0.0. The file identifier and extension remain
`com.muhiro12.Incomes.data` and `.incomes`.

The 6.1 contract deliberately does not read the single-version file introduced
in 6.0 or the earlier development V2 payload. Their readers are removed rather
than retaining a second versioning policy. This changes file interchange only;
existing on-device and iCloud records do not require a new storage schema.

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
- The item's saved running balance, retained by default when restoring that item.
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
`com.muhiro12.Incomes.data` conforms to `public.json`.

The `fileType` header carries that type identifier. The earlier `format`
header is unsupported, including the lowercase development namespace. The new
writer omits `format`, so a 6.0 reader rejects the file before routing its schema
2.0.0 value to the obsolete default-book-only payload reader. There is no alias,
legacy reader, downgrade writer, or rewriting of existing external files.

Reading and writing share a 32 MiB limit. Export refuses a larger payload so it
cannot produce a file this version cannot restore. The URL reader bounds the
bytes loaded even if the file size changes after selection.

```json
{
  "exportedAt": "2026-09-29T03:04:05Z",
  "fileType": "com.muhiro12.Incomes.data",
  "formatVersion": 1,
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
  "schemaVersion": "2.0.0",
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
- `balance` is optional. Import retains supplied balances as saved baselines by
  default. A difference from recalculation is not proof of an error: the saved
  balance may already match the person's real money. When the review detects a
  difference, the person can explicitly choose recalculation instead.
- `priority` is an integer and `repeatID` is a UUID string.

### Preserving order during export

Native identity breaks ties when items share a ledger, date, priority, and
description. Those identities change after restoration. For each affected
ledger-day, export adjusts priorities in the file copy to preserve the source's
complete chronological order. It uses the editor's existing `0...10` range;
ascending descriptions can still share a priority. Other ledger-days stay
unchanged. The person reviews a disclosure before saving the file, and the live
store, saved balances, and synced priorities do not change.

Using every priority value does not itself exhaust capacity: neighboring items
with ascending descriptions can share a value to leave room for a native tie.

If the day's order needs more priority levels than the range allows, the entire
day retains its original priorities. Export and import warn that the order and
displayed running balances may change on restoration. This bounded fallback
does not add ordering fields or expand the editor's priority range.

## Extension rules

Ignorable fields and must-understand selection filters provide bounded
extension points within a supported version pair.

Sections describe which kinds of data the file contains. `items` is required
and `settings` is optional. Planned sections include category attributes
and notification settings. Format 1 requires the ledger metadata section
`ledgers`.

- A section or field that a reader can ignore without changing the meaning of
  the remaining data may be added within the same supported version pair.
  Readers ignore unknown keys.
- Data whose omission would change meaning, such as ledger ownership, requires
  an appropriate new schema or format revision.

`selection.ledgerIDs` explicitly lists covered owners. An empty
`selection.filters` list means all Items within those owners. Replacing this
selection cannot erase another owner. The current full export includes the
default book even when it is empty. Planned filter kinds include a date range
and categories.

Format 1 refuses duplicate book IDs. Additional-book names are metadata, not
identity; same-name books stay distinct. Merge retains existing names unless explicitly
changed in review. See [Independent ledgers](independent-ledgers.md).

- Filters are must-understand. A reader rejects a file containing a filter kind
  it does not know, instead of mistaking a partial file for a complete one.
  An older reader still refuses an unknown filter before mutation.
- The selection also defines the scope of a replacement import: replacing with
  a file covering 2026 replaces only 2026 records. A file without a
  `selection` key is invalid in format 1.

## Versioning

The two fields have different responsibilities:

| Field | Source and meaning |
| --- | --- |
| `schemaVersion` | The writing `VersionedSchema.versionIdentifier`, currently `IncomesSchemaV2` / `2.0.0` |
| `formatVersion` | File structure, representation, and decoding conventions, currently `1` |

Export derives the schema declaration from the actual versioned model rather
than maintaining another schema number. A storage revision changes that
declaration even when the portable representation is unchanged; register an
explicit reader for the new pair and reuse a payload decoder when appropriate.
A file-only change advances the format revision without manufacturing a
SwiftData schema. A change affecting both may advance both.

Only explicitly supported pairs are readable. Unknown future format or schema
versions are rejected before item decoding and mutation. Support is not the
Cartesian product of every historical format and storage schema.

From this baseline, freeze each published payload and its fixture. Retain
historical Foundation value readers for supported pairs and convert into the
current import candidate. A temporary database or execution of
`SchemaMigrationPlan` is not required for file input. Store migration and file
adapters share preservation rules for exact money, saved balances, calendar
days, recurrence, and ledger ownership; share pure conversion helpers only
where there is actual common transformation logic.

A future adapter must distinguish a field absent from an older schema from an
explicit empty/null value in a schema that defines it. Do not silently clear
existing information that an old file cannot represent, or invent a fact for a
newly created record. Carry availability in the transient candidate when
needed; do not add provenance columns or a generic migration framework now.
Keep these rules within the existing matching and reviewed merge/replace
policies.

`Tests/Default/Fixtures/IncomesFile-1-Schema-2.0.0/` records the new pair's exact
values and bytes, including empty additional ledgers. The untouched synthetic
6.0 file is retained only as an unsupported-input fixture; it has no decoder.
Native store migration fixtures remain separate evidence under
[SwiftData storage history](swiftdata-schema-evolution.md). File round trips do
not establish native-store migration or CloudKit convergence.

## Import flow

1. Read the file, check its size limit, format, and version, then validate every
   item before anything is written.
2. Compare the file with the store and show the difference.
3. Apply the chosen policy only after explicit confirmation. The operation
   inserts, deletes, removes unused tags, and applies the chosen balance policy. The
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
  `balance` is excluded so a balance difference never creates duplicate records.
  The review snapshot still includes saved balances to detect stale reviews.
- Items are matched by counting equal keys on both sides. If the file holds
  three equal items and the store holds two, two match and one remains on the
  file side. Complete matches, including repeat ID and saved balance, are
  retained first so duplicate transactions do not exchange saved baselines.
  Remaining matches use the regular key; balance or recurrence differences
  alone still do not create duplicate transactions.

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
  - Matched transaction values are left unchanged; affected running balances
    follow the balance policy below.
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

### Saved balances

The default policy retains balances supplied by inserted file items. Missing
file balances and later affected store items are calculated from the preceding
retained baseline. A priority-only replacement with unchanged transactions in
a ledger also retains the existing matched balances in that ledger. This
preserves the file exactly when restoring all its records into an empty store
without silently rebuilding earlier history.

The review compares this result with recalculation. If they differ, a toggle
offers recalculation, off by default. It changes only the affected suffix in
each ledger, starting at the earliest inserted or removed date and retaining
the preceding saved balance. It does not repair matching earlier records or
another ledger. A recalculation that exceeds the exact amount boundary is
disabled; valid saved baselines can still be restored. Choosing another file or
refreshing a stale review clears the choice.

The priority preparation described above preserves native tie order where the
existing range permits it. Unresolved ties still use destination model identity.
Keeping every exported balance therefore does not guarantee the same final
displayed balance for that group. This is separate from the explicit
recalculation choice.

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

## App Intent adapters

`PreviewDataImportIntent` reads and validates the same file and reports the
planned merge/replace counts without writing. `ExportDataIntent` returns an
`IntentFile` from the canonical export preparation and asks for confirmation
when file-only priorities need disclosure. `ImportDataIntent` requires an
explicit confirmation, preserves saved balances by default, and revalidates the
reviewed store and currency after suspension. It calls `DataImportCoordinator`
so entitlement, update checks, durable save, and follow-ups match the app.

File parameters accept JSON, to which the registered `.incomes` type conforms;
the existing codec still validates the exact format, version, and size. Export
and import execution remain hidden pending bulk-disclosure authentication and
system conflict-review qualification in
[#410](https://github.com/muhiro12/Incomes/issues/410). Import's coarse merge
policy retains current conflict groups; item-by-item conflict selection remains
in the app. These adapters do not add a persisted review token or another backup
format.
