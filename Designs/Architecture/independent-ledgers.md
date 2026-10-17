# Independent ledgers

## Current development scope

Incomes 6 adds independent books inside the existing Premium entitlement.
The first slice supports creating, naming, selecting, and editing additional
books, with separate Item lists, income, outgo, balances, and recurrence.
Compound interest, System Items, market valuations, automatic transfers,
combined reporting, and per-book currency are outside this slice.

Product decisions belong to
[#382](https://github.com/muhiro12/Incomes/issues/382);
implementation evidence belongs to
[#383](https://github.com/muhiro12/Incomes/issues/383).
The [product principles](../Overviews/incomes-product-principles.md) explain the
longer-lived judgment behind that scope.

## Identity and ownership

- The default book uses a dedicated `TagType.defaultLedger` Tag. Its `typeID`
  is one fixed kind identifier and its `name` is plain text. No stored field or
  model is added. The default role maps to the existing `.default` selection
  and file reference, independently of a particular Tag's native identity.
  Separately created default Tags describe this same role, including during sync;
  they do not create independent standard books or require distributed uniqueness.
- An additional ledger is one Tag. `typeID` stores the single raw value of
  `TagType.ledger`, just as other Tag kinds do. `name` stores only its editable
  name. Neither field embeds an identifier or a structured payload.
- The Tag's native persistent identifier distinguishes ledgers within a store.
  Selection and drafts capture that identifier, so a rename preserves ownership
  and does not redirect an outstanding edit to a newly created same-name ledger.
- Items belong to a book through an ownership Tag relationship. No ownership
  Tag means **unassigned**, never implicit default ownership. More than
  one distinct book identity is a conflict, never an instruction to sum or
  duplicate the Item. Scoped queries exclude conflicting memberships.
- Queries filter ordinary date, amount, and kind conditions in SwiftData, then
  check the current Tag graph for exact ownership before applying result limits.
  On iOS 18, nested Tag-ID predicates can return Items from another ledger;
  those query results must not decide ledger membership. `ItemFetchDescriptor`
  owns that filtering contract. The app's small `LedgerItemQuery` wrapper keeps
  `@Query` observation and filters the current live models without copying them
  into presentation state.
- Normal creation and rename reject another ledger with the same name. If sync
  or another writer nevertheless creates duplicate Tags, their native identities
  keep their Items and balances separate. The existing duplicate-tag workflow
  lists them and merges them only after an explicit user action and confirmation.
  Existing classification-maintenance shortcuts do not merge ledger Tags.
  That explicit merge combines the selected ledgers' Items and recalculates their balances
  in the same save boundary; an error rolls it back. Orphan cleanup still excludes
  ledger Tags, so an empty ledger persists. Ledger deletion and archiving are not
  exposed in this slice.
- Year, month, content, and category Tags remain shared vocabulary. Financial
  reads and category renames scope the related Items to the selected book.
  Period navigation resolves a representative Tag used by that book's Items,
  including when duplicate physical Tags exist. A scoped category rename returns
  its saved destination Tag so the screen and intent keep the correct selection.
- Drafts, inference inputs, recurrence, duplication, and balance reviews capture
  their original book. A selection change must not redirect a pending save.

## Calculations and surfaces

Balances are derived from each book's ordered authoritative income and outgo.
Read paths do not trust a saved `Item.balance` written by an older global
calculator. Derived-cache repair is separate from reading and cannot insert
financial records.

Unassigned or conflicting ownership can affect any book. The app shows the issue,
offers an unassigned-item review, and withholds complete ledger balances until
ownership is resolved. Monthly widget summaries, Watch snapshot refresh, balance
projections, and generated monthly narratives also refuse incomplete ownership.
Cache repair does not assign Items. The review assigns only selected unassigned
Items to an explicit destination and preserves their IDs, amounts, dates, and
repeat identity. It rechecks selection and destination and validates the resulting
balances before mutation, then saves relationships and balances together. Premium
is required for an additional-book destination, not the default book.

The app selects books per window. Existing unqualified month/year routes,
Widgets, Watch snapshots, and ordinary Shortcut creation retain the default
book. An explicit Item route resolves the Item's current book. The companion
surfaces label the default-book scope; broader selection can follow separately.

Premium expiry preserves view, selection, and export access. The default book
stays editable; additional-book mutations require Premium at the adapter
boundary, including import and system entry points. Entitlement is not stored
in financial models.

The existing backup feature captures book identities, names, and empty books
in file version 3.0.0. It remains available without Premium and is not an
activation prerequisite. Legacy V2 files resolve only to the default book.
File references are opaque digests of the source Tag identity; the file never
contains a SwiftData persistent identifier or its store payload. The digest stays
stable through a source-store rename, but is not a portable model identifier.
Import resolves references against the destination before comparison. An
existing local identity or its matching file reference wins;
otherwise a unique matching name is compared in the normal import review. New
ledgers get new destination Tags. Ambiguous names refuse import rather than
guessing or combining distinct ledgers. Export again after resolving duplicate
names when an older file can no longer be mapped unambiguously.

The feature is called **Ledger** in English and code, and **帳簿** in Japanese.
It groups planned income, outgo, and balances; it does not imply a connected bank
account or a separate login. See [product vocabulary](product-vocabulary.md).

## Compatibility and operational scope

The 5.12 writer rebuilds Item Tags without ownership Tags. An old-client edit can
therefore remove either standard or additional membership. The new reader detects
the resulting unassigned Item instead of silently including it in the default
book. Detection cannot identify the former owner or prevent an old offline writer.
A remaining empty book Tag cannot identify its former members.

At host startup, the existing `lastLaunchedAppVersion` preference selects a local
legacy upgrade. If the previous version is older than 6.0 (or absent), and the
store contains no additional-book metadata, existing
unassigned Items receive a standard Tag in one save. Financial values and model
identities remain unchanged. Startup records the current app version only after
successful preparation. A failed startup keeps the previous version available
for retry. No additional migration flag or stored schema version is introduced:
the persisted V2 shape is shared by 5.12 and 6.0 and cannot distinguish them.

Additional-book metadata takes precedence over the version preference, including
after a downgrade. A standard Tag arriving from another device does not prevent
a legacy single-book upgrade. A standard Tag is also created for an empty dataset.
Later untagged arrivals, current-version launches with missing metadata, and mixed
datasets stay unassigned for review; startup and balance repair do not guess their
destination. Sync can temporarily deliver an Item before its ownership relation;
the notice asks the user to wait before assigning it. The save rechecks that every
selected Item is still unassigned.

This is a deliberately bounded migration, not proof of every device's history.
An absent/old local version plus absent local additional-book metadata cannot
establish that no other device has ever created additional books. The legacy path prefers
the standard book in that irregular case. It never deletes financial records.
Real cloud delivery and multi-device convergence remain separate release checks.

Ledger management explains that earlier versions combine all ledgers and can
remove an Item's assignment when editing. The first additional-ledger creation
shows the warning again and asks the user to confirm that every device runs
Incomes 6.0 or later. If a device cannot be updated, the notice directs the user
to continue with the default ledger only. This uses existing ledger inventory,
not another persisted acknowledgement flag. Import review also shows the
mixed-version warning when a file contains additional ledgers.

The notice is an operational prerequisite, not proof of device versions and not
a technical write barrier. It cannot prevent an offline old writer or recover
a lost relationship. Mixed-version editing is not a data-preservation guarantee.
Explicit standard Tags make subsequent missing ownership detectable; they do not
recover the lost relationship. Incomes files retain their existing explicit
default reference and restore it through a standard Tag. Unassigned Items cannot
be silently exported as default Items; resolve their ownership before file export.

The existing remote update request can reduce exposure after 6.0 is publicly
available, but its UI alert does not gate every write entry point. A stronger
shared mechanism is tracked in
[MHPlatform #15](https://github.com/muhiro12/MHPlatform/issues/15); new code cannot
retrofit enforcement into the distributed 5.12 binary. No required-version
configuration or production CloudKit setting changes as part of this work.
Backup remains optional and is recovery assistance rather than prevention.
Preserve the probe history in #382 and the cloud follow-ups in
[#377](https://github.com/muhiro12/Incomes/issues/377) and
[#378](https://github.com/muhiro12/Incomes/issues/378).
