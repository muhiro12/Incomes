import Foundation
import SwiftData
import Testing

@testable import IncomesLibrary

@MainActor
struct LedgerOperationsTests {
    @Test
    func sameNamesAndEmptyBooksKeepIndependentIdentities() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let first = try LedgerOperations.create(context: context, name: "Savings")
        let second = try LedgerOperations.create(context: context, name: "Savings")
        #expect(first.id != second.id)
        #expect(try LedgerOperations.accounts(context: context).count == 3)
        #expect(try context.fetchCount(FetchDescriptor<Item>()) == 0)
        #expect(try context.fetchCount(.tags(.all)) == 0)
        #expect(try context.fetchCount(.tags(.typeIs(.ledger))) == 2)
    }

    @Test
    func ordinaryTagMaintenancePreservesEmptyBookMetadata() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let first = try LedgerOperations.create(context: context, name: "Same")
        let second = try LedgerOperations.create(context: context, name: "Same")
        _ = try Tag.create(context: context, name: "Unused", type: .category)
        try context.save()
        #expect(try TagMutationOperations.deleteAllOrphanTags(context: context) == 1)
        let metadata = try context.fetch(.tags(.typeIs(.ledger)))
        TagMutationOperations.mergeDuplicates(tags: metadata)
        try context.save()
        #expect(try LedgerOperations.account(first.id, context: context).isAvailable)
        #expect(try LedgerOperations.account(second.id, context: context).isAvailable)
        #expect(try context.fetchCount(.tags(.typeIs(.ledger))) == 2)
    }

    @Test
    func renameAndOrdinaryEditKeepTheSameOwner() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let account = try LedgerOperations.create(context: context, name: "Original")
        let item = try createItem(context: context, owner: account.id, income: 100)
        try context.save()
        let originalID = item.persistentModelID
        try LedgerOperations.rename(account.id, to: "Renamed", context: context)
        try item.modify(
            values: .init(
                date: .now,
                content: "Edited",
                income: 200,
                outgo: 0,
                category: "Changed",
                priority: 0,
                ledgerIdentifier: account.id
            ),
            repeatID: item.repeatID
        )
        #expect(try LedgerOperations.account(account.id, context: context).name == "Renamed")
        #expect(item.ledgerIdentifier == account.id)
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
    func duplicatePortableIdentityRefusesMutation() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let identifier = LedgerIdentifier()
        for name in ["A", "B"] {
            _ = Tag.createLedger(context: context, identifier: identifier, name: name)
        }
        try context.save()
        #expect(try LedgerOperations.account(identifier, context: context).issue == .duplicateIdentifier)
        #expect(throws: LedgerError.duplicateIdentifier) {
            try LedgerOperations.rename(identifier, to: "Chosen", context: context)
        }
        #expect(try context.fetchCount(.tags(.typeIs(.ledger))) == 2)
    }

    @Test
    func multipleOwnershipTagsCannotEnterEitherBookOrTheDefaultBook() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let first = try LedgerOperations.create(context: context, name: "Same")
        let second = try LedgerOperations.create(context: context, name: "Same")
        let item = try createItem(context: context, owner: first.id, income: 100)
        let secondTag = try LedgerOperations.metadataForMutation(second.id, context: context)
        item.modify(tags: (item.tags ?? []) + [secondTag])
        try context.save()
        #expect(item.ledgerIdentifier == .conflicting)
        for identifier in [LedgerIdentifier.default, first.id, second.id] {
            #expect(try context.fetchCount(.items(.all, ledgerIdentifier: identifier)) == 0)
        }
        #expect(
            try LedgerOperations.accounts(context: context).contains { $0.issue == .conflictingOwnership }
        )
    }

    @Test
    func scopedBalancesIgnoreOldGlobalWriterValuesBeforeAnyRepair() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let account = try LedgerOperations.create(context: context, name: "Other")
        let standard = try createItem(context: context, owner: .default, income: 100)
        let other = try createItem(context: context, owner: account.id, income: 500)
        standard.modify(balance: 900)
        other.modify(balance: 999)
        try context.save()
        #expect(try LedgerBalanceOperations.snapshot(context: context).latestBalance == 100)
        #expect(
            try LedgerBalanceOperations.snapshot(context: context, ledgerIdentifier: account.id).latestBalance
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
        let account = try LedgerOperations.create(context: context, name: "Other")
        let standard = try createItem(context: context, owner: .default, income: 100)
        let other = try createItem(context: context, owner: account.id, income: 500)
        try context.save()
        let category = try #require(other.category)
        #expect(category.id == standard.category?.id)
        try TagRenameOperations.renameCategory(
            context: context,
            tag: category,
            to: "Renamed",
            ledgerIdentifier: account.id
        )
        #expect(other.category?.name == "Renamed")
        #expect(standard.category?.name == "General")
        #expect(other.ledgerIdentifier == account.id)
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
