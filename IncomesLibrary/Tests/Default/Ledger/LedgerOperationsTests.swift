import Foundation
import SwiftData
import Testing

@testable import IncomesLibrary

@MainActor
struct LedgerOperationsTests {
    @Test
    func normalCreationRejectsDuplicateNamesAndKeepsEmptyLedgers() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let first = try LedgerOperations.create(context: context, name: "Savings")
        #expect(throws: LedgerError.duplicateName) {
            try LedgerOperations.create(context: context, name: "Savings")
        }
        let second = try LedgerOperations.create(context: context, name: "Other")
        #expect(first.id != second.id)
        #expect(try LedgerOperations.ledgers(context: context).count == 3)
        #expect(try context.fetchCount(FetchDescriptor<Item>()) == 0)
        #expect(try context.fetchCount(.tags(.all)) == 0)
        #expect(try context.fetchCount(.tags(.typeIs(.ledger))) == 2)
        #expect(throws: LedgerError.duplicateName) {
            try LedgerOperations.rename(first.id, to: second.name, context: context)
        }
    }

    @Test
    func ordinaryTagMaintenancePreservesEmptyBookMetadata() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let first = try LedgerOperations.create(context: context, name: "Same")
        let second = try LedgerOperations.create(context: context, name: "Other")
        _ = try Tag.create(context: context, name: "Unused", type: .category)
        try context.save()
        #expect(try TagMutationOperations.deleteAllOrphanTags(context: context) == 1)
        let metadata = try context.fetch(.tags(.typeIs(.ledger)))
        #expect(metadata.allSatisfy { $0.typeID == TagType.ledger.rawValue })
        #expect(try LedgerOperations.ledger(first.id, context: context).isAvailable)
        #expect(try LedgerOperations.ledger(second.id, context: context).isAvailable)
        #expect(try context.fetchCount(.tags(.typeIs(.ledger))) == 2)
    }

    @Test
    func renameAndOrdinaryEditKeepTheSameOwner() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let ledger = try LedgerOperations.create(context: context, name: "Original")
        let item = try createItem(context: context, owner: ledger.id, income: 100)
        try context.save()
        let originalID = item.persistentModelID
        try LedgerOperations.rename(ledger.id, to: "Renamed", context: context)
        try item.modify(
            values: .init(
                date: .now,
                content: "Edited",
                income: 200,
                outgo: 0,
                category: "Changed",
                priority: 0,
                ledgerIdentifier: ledger.id
            ),
            repeatID: item.repeatID
        )
        #expect(try LedgerOperations.ledger(ledger.id, context: context).name == "Renamed")
        #expect(item.ledgerIdentifier == ledger.id)
        #expect(item.persistentModelID == originalID)
        #expect((item.tags ?? []).filter { $0.type == .ledger }.count == 1)
    }

    @Test
    func theOriginalBookNeedsNoOwnershipTag() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let item = try createItem(context: context, owner: .default, income: 100)
        #expect(item.ledgerIdentifier == .default)
        #expect((item.tags ?? []).allSatisfy { $0.type != .ledger })
        #expect(try context.fetchCount(.items(.all)) == 1)
        #expect(try context.fetchCount(.tags(.typeIs(.ledger))) == 0)
    }

    @Test
    func accidentalSameNameTagsStayIndependentUntilTheUserMergesThem() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let firstTag = Tag.createIgnoringDuplicates(context: context, name: "Same", type: .ledger)
        let secondTag = Tag.createIgnoringDuplicates(context: context, name: "Same", type: .ledger)
        try context.save()
        let first = try #require(LedgerOperations.identifier(for: firstTag))
        let second = try #require(LedgerOperations.identifier(for: secondTag))
        #expect(first != second)
        let standard = try createItem(context: context, owner: .default, income: 5)
        let left = try createItem(context: context, owner: first, income: 10)
        let right = try createItem(context: context, owner: second, income: 20)
        try context.save()
        let itemIDs = Set([standard.id, left.id, right.id])
        #expect(TagQueryOperations.items(for: firstTag).map(\.id) == [left.id])
        #expect(TagQueryOperations.items(for: secondTag).map(\.id) == [right.id])
        for identifier in [first, second, first] {
            let expected = identifier == first ? left.id : right.id
            #expect(try context.fetch(.items(.all, ledgerIdentifier: identifier)).map(\.id) == [expected])
        }
        #expect(try LedgerBalanceOperations.snapshot(context: context, ledgerIdentifier: first).latestBalance == 10)
        #expect(try LedgerBalanceOperations.snapshot(context: context, ledgerIdentifier: second).latestBalance == 20)
        #expect(try context.fetchCount(.tags(.typeIs(.ledger))) == 2)
        let duplicates = try TagQueryOperations.duplicateTags(context: context, type: .ledger)
        #expect(duplicates.count == 1)
        try TagMutationOperations.resolveDuplicatesAndSave(context: context, tags: duplicates)
        let surviving = try #require(try context.fetch(.tags(.typeIs(.ledger))).first)
        let owner = try #require(LedgerOperations.identifier(for: surviving))
        #expect(try context.fetchCount(.tags(.typeIs(.ledger))) == 1)
        #expect(left.ledgerIdentifier == owner && right.ledgerIdentifier == owner)
        #expect(try LedgerBalanceOperations.snapshot(context: context, ledgerIdentifier: owner).latestBalance == 30)
        #expect(standard.ledgerIdentifier == .default)
        #expect(try Set(context.fetch(.allLedgerItems()).map(\.id)) == itemIDs)
        #expect(!context.hasChanges)
    }

    @Test
    func multipleOwnershipTagsCannotEnterEitherBookOrTheDefaultBook() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let first = try LedgerOperations.create(context: context, name: "Same")
        let second = try LedgerOperations.create(context: context, name: "Other")
        let item = try createItem(context: context, owner: first.id, income: 100)
        let secondTag = try LedgerOperations.metadataForMutation(second.id, context: context)
        item.modify(tags: (item.tags ?? []) + [secondTag])
        try context.save()
        #expect(item.ledgerIdentifier == .conflicting)
        for identifier in [LedgerIdentifier.default, first.id, second.id] {
            #expect(try context.fetchCount(.items(.all, ledgerIdentifier: identifier)) == 0)
        }
        #expect(
            try LedgerOperations.ledgers(context: context).contains { $0.issue == .conflictingOwnership }
        )
    }

    @Test
    func existingClassificationMaintenanceCannotImplicitlyMergeLedgers() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        for type in [TagType.ledger, .category] {
            _ = Tag.createIgnoringDuplicates(context: context, name: "Same", type: type)
            _ = Tag.createIgnoringDuplicates(context: context, name: "Same", type: type)
        }
        try context.save()
        #expect(try TagMutationOperations.resolveAllDuplicates(context: context) == 1)
        try context.save()
        #expect(try context.fetchCount(.tags(.typeIs(.ledger))) == 2)
        #expect(try context.fetchCount(.tags(.typeIs(.category))) == 1)
        #expect(try TagQueryOperations.duplicateTags(context: context, type: .ledger).count == 1)
    }

    @Test
    func scopedBalancesIgnoreOldGlobalWriterValuesBeforeAnyRepair() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let ledger = try LedgerOperations.create(context: context, name: "Other")
        let standard = try createItem(context: context, owner: .default, income: 100)
        let other = try createItem(context: context, owner: ledger.id, income: 500)
        standard.modify(balance: 900)
        other.modify(balance: 999)
        try context.save()
        #expect(try LedgerBalanceOperations.snapshot(context: context).latestBalance == 100)
        #expect(
            try LedgerBalanceOperations.snapshot(context: context, ledgerIdentifier: ledger.id).latestBalance
                == 500
        )
        #expect(standard.balance == 900 && other.balance == 999)
        try ItemBalanceOperations.reconcileAndSave(context: context)
        #expect(standard.balance == 100 && other.balance == 500)
        try ItemBalanceOperations.reconcileAndSave(context: context)
        #expect(!context.hasChanges)
    }

    @Test
    func categoryRenameOnlyChangesItemsInItsBook() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let ledger = try LedgerOperations.create(context: context, name: "Other")
        let standard = try createItem(context: context, owner: .default, income: 100)
        let other = try createItem(context: context, owner: ledger.id, income: 500)
        try context.save()
        let category = try #require(other.category)
        #expect(category.id == standard.category?.id)
        try TagRenameOperations.renameCategory(
            context: context,
            tag: category,
            to: "Renamed",
            ledgerIdentifier: ledger.id
        )
        #expect(other.category?.name == "Renamed")
        #expect(standard.category?.name == "General")
        #expect(other.ledgerIdentifier == ledger.id)
    }

    @Test
    func ledgerFeatureDoesNotExtendTheReleasedStoredShape() {
        let schema = Schema(versionedSchema: IncomesSchemaV2.self)
        #expect(schema.entities.count == 2)
        #expect(schema.entities.first { $0.name == "Item" }?.attributesByName["ledgerID"] == nil)
        #expect(schema.entities.first { $0.name == "Tag" }?.attributesByName["forecastSettingsJSON"] == nil)
    }
}

private extension LedgerOperationsTests {
    func createItem(
        context: ModelContext,
        owner: LedgerIdentifier,
        income: Decimal,
        repeatID: UUID = UUID()
    ) throws -> Item {
        try Item.create(
            context: context,
            values: .init(
                date: .now,
                content: "Overlapping entry",
                income: income,
                outgo: .zero,
                category: "General",
                priority: .zero,
                ledgerIdentifier: owner
            ),
            repeatID: repeatID
        )
    }
}
