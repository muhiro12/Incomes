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
- An additional book is one Tag. Its name is the editable display name; its
  `typeID` is `ledger:` followed by a generated UUID. That convention uses the
  existing stored fields and is a new domain contract, even without a schema
  change.
- Items belong to an additional book through that Tag relationship. More than
  one distinct book identity is a conflict, never an instruction to sum or
  duplicate the Item. Scoped predicates exclude conflicting memberships.
- Same-name books have distinct identities. Rename changes the name in place.
  Ordinary duplicate merging and orphan cleanup exclude book Tags, so an empty
  book persists. The initial slice does not expose book deletion or archiving.
- Year, month, content, and category Tags remain shared vocabulary. Financial
  reads and category renames scope the related Items to the selected book.
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

## Compatibility limits before release

The initial implementation deliberately retains the small no-Tag default
representation. The 5.12 writer rebuilds Item Tags without unknown book Tags.
An old-client edit can therefore remove additional-book membership and make the
Item look like a default-book Item. A remaining empty book Tag cannot identify
its former members. Recomputing balances cannot recover that lost relationship.

Updating every device before using additional books reduces exposure; the
current update alert does not block offline writers or every system surface.
The implementation is not mixed-version CloudKit qualification or release
clearance. Before release, settle whether operational constraints are enough,
whether the default book needs explicit Tags and missing-membership handling,
or whether another ownership representation is required. Do not describe the
current Tag-only design as proven safe with old writers. Preserve the probe
history in #382 and the cloud follow-ups in
[#377](https://github.com/muhiro12/Incomes/issues/377) and
[#378](https://github.com/muhiro12/Incomes/issues/378).
