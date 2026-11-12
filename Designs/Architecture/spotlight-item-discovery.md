# Spotlight Item Discovery

Issue [#393](https://github.com/muhiro12/Incomes/issues/393) tracks discovery of
saved items in Spotlight and Siri. The current SwiftData `Item` and `Tag`
models have no `.spotlight` attributes. That SwiftData option is distinct from
explicitly indexing an `AppEntity` so that the system can resolve its identity
and open it in the app.

## Data exposure

`ItemEntity` is already used by Shortcuts and onscreen annotations. Its title
contains the item date and name, its subtitle contains both amounts, and its
image indicates the direction of the amount. Core Spotlight derives metadata
from the entity's display representation. Overriding `attributeSet` alone is
insufficient evidence that this existing presentation stays out of search
results. Item names and content tags can also contain personal details.

The candidate is a separate search entity that receives only an approved item
title and the existing store-local item identifier. Start with items, omit
amounts, dates, direction, category and ledger names, and use a named index
with `.complete` file protection. Choose whether item names can appear in
system search and whether indexing is opt-in before connecting it to a real
store. Verify what Siri and Spotlight actually reveal, including while locked.

## Lifecycle and opening

- Resolve the identifier against the current store at open time and reuse the
  existing item route, including its ledger selection. A missing result should
  fail closed instead of selecting another item with the same name. The
  identifier remains local to this store, as tracked in [#409].
- Update the index only from committed records. Cover create, rename, delete,
  repeating mutations, restore and incoming sync; a failed save or fetch must
  not be interpreted as an empty store. Keep indexing failures separate from
  successful financial saves and reconcile them on a later foreground pass.
- Reuse the same projection and named index for the iOS 27
  `IndexedEntityQuery` callbacks. Rebuild or purge the index after a change in
  eligibility, store identity or policy. `IndexedEntity` and explicit index
  updates are available on the iOS 18 baseline independently of those callbacks.
- Verify add, rename, delete, and reindex using synthetic items first. Check
  duplicate names, restored stores, locked-device results, and the exact item
  opened from Spotlight. Validate spoken targeting separately on a device with
  Siri enabled.

A synthetic probe compiled the entity, named protected index, and reindex
methods against the iOS 27.2 SDK with an iOS 18 deployment target. On macOS
27.2, constructing `CSSearchableItem` from the narrow entity produced the
expected title. The probe did not write an index or establish iOS search,
subtitle redaction, or Siri behavior.

[#409]: https://github.com/muhiro12/Incomes/issues/409

## References

- [Making app entities available in Spotlight](https://developer.apple.com/documentation/appintents/making-app-entities-available-in-spotlight)
- [Creating a named index with data protection](https://developer.apple.com/documentation/corespotlight/cssearchableindex/init(name:protectionclass:))
