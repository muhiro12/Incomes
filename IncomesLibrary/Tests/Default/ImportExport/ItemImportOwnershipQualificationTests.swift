import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

/// Qualifies the current import contract before introducing financial owners.
/// Owner partitions below are test-only sets of saved IDs, not a proposed schema.
@MainActor
struct ItemImportOwnershipQualificationTests {
    @Test(arguments: [false, true], [false, true])
    func repeated_fixture_import_preserves_saved_identity_and_current_series(
        replace: Bool,
        editedSeries: Bool
    ) throws {
        try withStore { url in
            let contents = try fixtureContents()
            try withContext(at: url) { context in
                _ = try importAndSave(contents, context: context)
            }
            let before = try withContext(at: url) { context in
                if editedSeries {
                    let item = try #require(fetchItems(context).first { $0.content == "Rent" })
                    try item.modify(values: IncomesFileItem(item: item).storedValues, repeatID: UUID())
                    try context.save()
                }
                return try snapshot(context)
            }
            try withContext(at: url) { context in
                try reimportWithoutChanges(contents, replace: replace, context: context)
            }
            let after = try withContext(at: url, body: snapshot)
            #expect(after == before)
            if !editedSeries {
                #expect(after.items == contents.items)
            }
        }
    }

    @Test
    func global_value_matching_cannot_distinguish_equal_rows_in_two_owner_partitions() throws {
        try withStore { url in
            try withContext(at: url) { context in
                let contents = try fixtureContents()
                let partitions = try seedEqualCopies(contents, context: context)
                let allRows = try storeRows(context)
                let global = try ItemImportOperations.difference(contents: contents, context: context)
                #expect(global.matchedCount == contents.items.count)
                #expect(global.storeOnlyItems.count == contents.items.count)
                let globalReplacement = ItemImportPlan(difference: global, policy: .replace)
                #expect(globalReplacement.removedItemIDs.count == contents.items.count)
                #expect(globalReplacement.insertedItems.isEmpty)
                for ownerIDs in partitions {
                    let owned = ownerDifference(contents, rows: allRows, ownerIDs: ownerIDs)
                    #expect(owned.isIdentical)
                    #expect(owned.matchedCount == contents.items.count)
                    let ownedReplacement = ItemImportPlan(difference: owned, policy: .replace)
                    #expect(ownedReplacement.removedItemIDs.isEmpty)
                    #expect(ownedReplacement.insertedItems.isEmpty)
                }
                #expect(partitions[0].isDisjoint(with: partitions[1]))
                #expect(!context.hasChanges)
            }
        }
    }

    @Test(arguments: [false, true])
    func an_owner_filtered_review_is_refused_by_the_unscoped_save_boundary(replace: Bool) throws {
        try withStore { url in
            try withContext(at: url) { context in
                let contents = try fixtureContents()
                let partitions = try seedEqualCopies(contents, context: context)
                let owned = ownerDifference(contents, rows: try storeRows(context), ownerIDs: partitions[0])
                let before = try snapshot(context)
                #expect(owned.isIdentical)
                #expect(throws: ItemImportError.storeChangedSinceReview) {
                    try ItemImportOperations.applyAndSaveWithOutcome(
                        contents: contents,
                        reviewed: owned,
                        policy: policy(replace: replace),
                        context: context
                    )
                }
                #expect(!context.hasChanges)
                let after = try snapshot(ModelContext(context.container))
                #expect(after == before)
            }
        }
    }

    @Test(arguments: [ItemMutationScope.futureItems, .allItems])
    func file_series_ids_cross_owner_partitions_in_the_current_mutation_scope(scope: ItemMutationScope) throws {
        try withStore { url in
            try withContext(at: url) { context in
                let contents = try fixtureContents()
                let partitions = try seedEqualCopies(contents, context: context)
                let items = try context.fetch(.items(.all, order: .forward))
                let target = try #require(items.first { item in
                    partitions[0].contains(item.persistentModelID) && item.content == "Rent"
                })
                let selected = try ItemMutationSupport.itemsForMutationScope(
                    context: context,
                    item: target,
                    scope: scope
                )
                let selectedIDs = Set(selected.map(\.persistentModelID))
                let sourceSeriesCount = contents.items.filter { $0.repeatID == target.repeatID }.count
                #expect(selected.count == sourceSeriesCount * partitions.count)
                for ownerIDs in partitions {
                    #expect(selectedIDs.intersection(ownerIDs).count == sourceSeriesCount)
                }
                #expect(!context.hasChanges)
            }
        }
    }
}

private extension ItemImportOwnershipQualificationTests {
    struct Snapshot: Equatable {
        let items: [IncomesFileItem]
        let itemIDs: Set<String>
        let tagIDs: Set<String>
    }

    func snapshot(_ context: ModelContext) throws -> Snapshot {
        let items = fetchItems(context)
        return try .init(
            items: ItemExportOperations.fileItems(items: items),
            itemIDs: Set(items.map { try PersistentIdentifierCoder.encode($0.persistentModelID) }),
            tagIDs: Set(context.fetch(.tags(.all)).map { try PersistentIdentifierCoder.encode($0.persistentModelID) })
        )
    }

    func storeRows(_ context: ModelContext) throws -> [ItemImportDifference.StoreItem] {
        try context.fetch(.items(.all)).map { item in
            .init(id: item.persistentModelID, item: .init(item: item))
        }
    }

    func ownerDifference(
        _ contents: IncomesFileContents,
        rows: [ItemImportDifference.StoreItem],
        ownerIDs: Set<PersistentIdentifier>
    ) -> ItemImportDifference {
        ItemImportComparer.difference(
            fileItems: contents.items,
            storeItems: rows.filter { ownerIDs.contains($0.id) }
        )
    }

    func seedEqualCopies(
        _ contents: IncomesFileContents,
        context: ModelContext
    ) throws -> [Set<PersistentIdentifier>] {
        let initial = try importAndSave(contents, context: context)
        let copies = try contents.items.map { item in
            try Item.create(context: context, values: item.storedValues, repeatID: item.repeatID)
        }
        try BalanceCalculator.calculate(in: context, after: .distantPast)
        try context.save()
        // These saved-ID sets only label hypothetical owners inside the test.
        return [initial.outcome.changedIDs.created, Set(copies.map(\.persistentModelID))]
    }

    func importAndSave(
        _ contents: IncomesFileContents,
        context: ModelContext
    ) throws -> MutationResult<ItemImportResult> {
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        return try ItemImportOperations.applyAndSaveWithOutcome(
            contents: contents,
            reviewed: difference,
            policy: .merge(.init()),
            context: context
        )
    }

    func reimportWithoutChanges(
        _ contents: IncomesFileContents,
        replace: Bool,
        context: ModelContext
    ) throws {
        let difference = try ItemImportOperations.difference(contents: contents, context: context)
        #expect(difference.isIdentical)
        #expect(difference.matchedCount == contents.items.count)
        let mutation = try ItemImportOperations.applyAndSaveWithOutcome(
            contents: contents,
            reviewed: difference,
            policy: policy(replace: replace),
            context: context
        )
        #expect(mutation.value == .init(addedCount: 0, removedCount: 0, unchangedCount: contents.items.count))
        #expect(mutation.outcome.changedIDs.created.isEmpty)
        #expect(mutation.outcome.changedIDs.updated.isEmpty)
        #expect(mutation.outcome.changedIDs.deleted.isEmpty)
        #expect(mutation.outcome.followUpHints.isEmpty)
        #expect(!context.hasChanges)
    }

    func policy(replace: Bool) -> ItemImportPolicy {
        replace ? .replace : .merge(.init())
    }

    func fixtureContents() throws -> IncomesFileContents {
        let url = try #require(Bundle.module.url(
            forResource: "Incomes",
            withExtension: "incomes",
            subdirectory: "Fixtures/IncomesFile-2.0.0"
        ))
        return try ItemImportOperations.read(data: Data(contentsOf: url))
    }

    func withContext<Output>(at url: URL, body: (ModelContext) throws -> Output) throws -> Output {
        try autoreleasepool {
            let container = try ModelContainerFactory.make(configuration: .init(url: url, cloudKitDatabase: .none))
            let context = ModelContext(container)
            context.autosaveEnabled = false
            return try body(context)
        }
    }

    func withStore(_ body: (URL) throws -> Void) throws {
        let directory = try persistentTestDirectory(fileManager: .default)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try body(directory.appendingPathComponent("Incomes.sqlite"))
    }
}
