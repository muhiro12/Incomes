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

- The default book has no dedicated ownership Tag. Existing records need no
  ownership migration and retain their stored model shape.
- An additional ledger is one Tag. `typeID` stores the single raw value of
  `TagType.ledger`, just as other Tag kinds do. `name` stores only its editable
  name. Neither field embeds an identifier or a structured payload.
- The Tag's native persistent identifier distinguishes ledgers within a store.
  Selection and drafts capture that identifier, so a rename preserves ownership
  and does not redirect an outstanding edit to a newly created same-name ledger.
- Items belong to an additional book through that Tag relationship. More than
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

The initial implementation deliberately retains the small no-Tag default
representation. The 5.12 writer rebuilds Item Tags without unknown book Tags.
An old-client edit can therefore remove additional-book membership and make the
Item look like a default-book Item. A remaining empty book Tag cannot identify
its former members. Recomputing balances cannot recover that lost relationship.

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
The current no-Tag default cannot distinguish a former additional-ledger Item
from an original default-ledger Item after the relation is gone. Explicit
default Tags and missing-membership handling remain a separate release decision;
their absence must not be reported as a verified old-writer safeguard.

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
