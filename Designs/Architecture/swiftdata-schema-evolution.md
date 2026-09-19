# SwiftData schema evolution

## Ownership and store identity

`IncomesLibrary` owns the models, versioned schemas, and container factory.
The host app relocates the legacy store before opening its container and runs
`IncomesSchemaMigrationPlan`. App Intents use that app container.

The store remains `Incomes.sqlite` in `group.com.muhiro12.Incomes`.
The legacy location is the application's Application Support directory.
The iCloud container remains `iCloud.com.muhiro12.Incomes`; the app preserves
its existing preference-controlled `.automatic` / `.none` selection.

Widgets use the same current schema, a read-only local configuration, and no
migration plan. They must not create the store before the app first opens it.
The providers already handle an unavailable container by returning their empty
entry. This is unavailable-data presentation, not evidence of an empty account.
Watch uses an independent in-memory snapshot populated through Watch sync.
It does not relocate or open the financial database on disk. Previews are also
in-memory with CloudKit disabled.

## Persisted model contract

| Entity | Stored field | Default / relationship |
| --- | --- | --- |
| Item | date | Reference-date zero; exposed as utcDate / localDate |
| Item | content | Empty string |
| Item | income, outgo, balance | Decimal zero |
| Item | priority | Integer zero |
| Item | repeatID | UUID; identifies a repeat series, not an individual row |
| Item | tags | Optional to-many; inverse Tag.items; nullify deletion |
| Tag | name, typeID | Empty string |
| Tag | items | Optional to-many; inverse Item.tags; nullify deletion |

The current model has no uniqueness constraints, `.deny` rules, external blobs,
or persisted enum payloads. `TagType` interprets the existing stable string IDs;
unknown values remain representable. Do not change those IDs during refactoring.
The optional relationships and declared scalar defaults accommodate CloudKit.
A shared tag does not own its items, so cascading tag deletion would be wrong.
Tag duplicate resolution remains explicit domain behavior; a UUID or a local
fetch-before-insert cannot guarantee distributed uniqueness.

`balance` and the classification tags are deliberately persisted derived data.
Operations maintain them. This maintenance change does not redefine financial
truth, recalculate historical balances, or merge categories. No new index is
introduced without a measured query need and a migration test.

`PersistentIdentifier` is a store-local reference used by existing routes.
Tests compare its encoded representation and resolve it in a reopened context.
Do not compare live managed object IDs from independent containers as if they
were portable values, or use them as cross-device business identifiers.

## Historical schemas

Schema versions describe storage and are independent of marketing versions.
The repository's release tags contain these three SwiftData shapes:

| Schema | Release tags | Difference |
| --- | --- | --- |
| V0 (0.0.0) | 2.0 through 2.4.2 | Also contains legacy group and startOfYear |
| V1 (1.0.0) | 2.5 through 5.2 | Removes the two legacy fields |
| V2 (2.0.0) | 5.3 through 5.12 and current 6.x | Adds priority with default zero |

V0 to V1 and V1 to V2 use lightweight stages. The V0 field removal reflects
the change already shipped in 2.5; retained tag relationships carry category
membership. This does not add a recovery path for old records whose category
exists only in the removed `group` field. Such legacy data needs a separately
verified transformation before claiming full archival recovery.

The current `Item` and `Tag` names alias models nested in `IncomesSchemaV2`.
Historical schemas refer to their own model types, never to those current
aliases. Preserve stored declarations, defaults, names, and relationship
metadata in every shipped schema. Methods and computed properties may evolve
without creating a storage version.

For a future storage change:

1. Add a new complete schema with its own model types; leave previous schemas
   unchanged. Point the public aliases and factory at the new current version.
2. Add the appropriate ordered stage. Use lightweight migration only when the
   transformation is supported. Custom stages must account for source-only
   `willMigrate` and destination-only `didMigrate` contexts.
3. Test direct upgrades from every historical shape, including skipped versions,
   and reopen the resulting store. Do not require intermediate app installs.
4. Preserve store URLs, App Group identifiers, CloudKit identity, and deployed
   field identities. Production CloudKit evolution is additive and needs its
   own verification with older clients.
5. Verify extension-first startup and host migration, then verify cloud import
   and export on signed devices before release.

## Relocation failures

Relocation is separate from schema migration. The public relocation entrypoint
throws, and app startup logs the failing phase and stops rather than opening a
replacement database. When both legacy and destination SQLite files exist,
`conflictingStores` preserves both and requires deliberate recovery. Never
choose the apparently newer or larger database automatically.

The relocation service validates the copied store with the current migration
plan and CloudKit disabled before removing the source. The existing service
handles SQLite sidecars. These models have no external-storage attributes;
adding one requires reviewing the relocation algorithm as well as the schema.
Do not copy a store while another process is writing it.

## Verification boundaries

`SchemaMigrationTests` creates disposable disk stores using independent,
unversioned fixtures derived from the persisted declarations in tags 2.4.2,
5.2, and 5.12. It checks decimal values, dates, repeat IDs, priority defaults,
encoded persistent IDs, shared tag inverses, repeated reopen, and nullify
behavior. These are reconstructed historical shapes compiled with the current
SDK, not store artifacts produced by every originally shipped executable.

`DatabaseMigratorTests` verifies copied-store opening, preservation on validation
failure, and preservation of both stores on a location conflict. A passing
local migration is not proof of CloudKit convergence or production-schema
compatibility. Before release, also validate archived-store copies from actual
shipped apps, supported older runtimes, fresh cloud imports, two-device sync,
and signed Widget/App Intent access. Pre-SwiftData Core Data (1.x) stores are
outside the reconstructed-fixture coverage.

## Official references and sample interpretation

- [Model your schema with SwiftData](https://developer.apple.com/videos/play/wwdc2023/10195/)
  and [inheritance and schema migration](https://developer.apple.com/videos/play/wwdc2025/291/)
  establish complete historical schemas and ordered migration stages.
- [SwiftData Group Lab](https://developer.apple.com/videos/play/wwdc2026/8017/)
  discusses adding versioning later and assigning migration ownership to the
  host app instead of widgets/extensions.
- [Apple DTS on unversioned migration](https://developer.apple.com/forums/thread/761735)
  describes wrapping the original complete model shape. The same discussion
  contains unresolved reports, so documentation does not replace disk tests.
- [CloudKit model synchronization](https://developer.apple.com/documentation/swiftdata/syncing-model-data-across-a-persons-devices)
  defines the sync-compatible model restrictions.
- [Backyard Birds](https://developer.apple.com/documentation/swiftui/backyard-birds-sample)
  demonstrates a shared model library and centralized complete schema across
  app surfaces. Its sample generation and force-try startup are not adopted.
- [Adding and editing persistent data](https://developer.apple.com/documentation/swiftdata/adding-and-editing-persistent-data-in-your-app)
  demonstrates explicit relationship semantics. Its unique category and cascade
  deletion serve that local sample and are unsuitable for Incomes' synced,
  shared tags.

The two sample sources were inspected from the external sample cache; their
Apple pages were checked on 2026-09-19. No sample was downloaded, replaced,
vended into this repository, or deleted during this audit.

## Preserve the deployed date field

The stored Item attribute remains `date`, which maps to CloudKit's `CD_date`
under Apple's [record mapping](https://developer.apple.com/documentation/coredata/reading-cloudkit-records-for-core-data).
The library exposes the computed `utcDate` and `localDate` properties to app
clients; database predicates and sort descriptors use the internal stored
attribute.

On iOS 27.0, a simulator export with `@Attribute(originalName: "date")` on a
stored `utcDate` property succeeded but produced `CD_utcDate` in the exported
record. The rename metadata preserved local migration values, but did not keep
the deployed CloudKit field identity. That experimental schema was not shipped
and is not part of the release migration plan. Do not repeat this rename based
only on successful local migration tests or successful CloudKit exports.

The schema contract test guards the persisted attribute name. Before changing a
synced field, verify its exported record representation, a fresh import, and
compatibility with supported older clients. Never deploy a development schema
change merely because an export succeeded.
