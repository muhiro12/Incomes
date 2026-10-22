import Foundation
import SwiftData
import Testing

@testable import IncomesLibrary

@MainActor
struct LedgerPersistenceTests {
    @Test(arguments: [false, true])
    func defaultNameSurvivesReopeningAndResetKeepsFinancialValues(autosaveEnabled: Bool) throws {
        let directory = try persistentTestDirectory(fileManager: .default)
        let url = directory.appendingPathComponent("default-name.store")
        let itemID: PersistentIdentifier
        let systemName: String
        do {
            let container = try ModelContainerFactory.make(
                configuration: .init(url: url, cloudKitDatabase: .none)
            )
            let context = ModelContext(container)
            let item = try makeItem(context: context, owner: .default, income: 100)
            item.modify(balance: 900)
            try context.save()
            itemID = item.id
            systemName = try LedgerOperations.ledger(.default, context: context).name
            context.autosaveEnabled = autosaveEnabled
            try LedgerOperations.rename(.default, to: "Household", context: context)
            #expect(context.autosaveEnabled == autosaveEnabled)
            #expect(!context.hasChanges)
        }
        do {
            let container = try ModelContainerFactory.make(
                configuration: .init(url: url, cloudKitDatabase: .none)
            )
            let context = ModelContext(container)
            #expect(try LedgerOperations.ledger(.default, context: context).name == "Household")
            let item = try #require(try ItemQueryOperations.item(context: context, persistentID: itemID))
            #expect(item.ledgerIdentifier == .default && item.balance == 900)
            try LedgerOperations.resetDefaultName(context: context)
        }
        let container = try ModelContainerFactory.readOnly(at: url)
        let context = ModelContext(container)
        let restored = try LedgerOperations.ledger(.default, context: context)
        #expect(restored.name == systemName && !restored.isNameCustomized)
        let item = try #require(try ItemQueryOperations.item(context: context, persistentID: itemID))
        #expect(item.ledgerIdentifier == .default && item.balance == 900)
        #expect(throws: CocoaError(.fileWriteNoPermission)) {
            try LedgerOperations.rename(.default, to: "Blocked", context: context)
        }
        #expect(throws: CocoaError(.fileWriteNoPermission)) {
            try LedgerOperations.resetDefaultName(context: context)
        }
        #expect(!context.hasChanges)
    }

    @Test
    func reopenedReadOnlyStoreKeepsRenamedAndEmptyBooksWithoutAnOwnershipColumn() throws {
        let directory = try persistentTestDirectory(fileManager: .default)
        let url = directory.appendingPathComponent("test.store")
        let owner: LedgerIdentifier
        let empty: LedgerIdentifier
        do {
            let container = try ModelContainerFactory.make(
                configuration: .init(url: url, cloudKitDatabase: .none)
            )
            let context = ModelContext(container)
            owner = try LedgerOperations.create(context: context, name: "Same").id
            empty = try LedgerOperations.create(context: context, name: "Empty").id
            _ = try makeItem(context: context, owner: .default, income: 10)
            _ = try makeItem(context: context, owner: owner, income: 20)
            try context.save()
            try LedgerOperations.rename(owner, to: "Renamed", context: context)
        }
        let reopened = ModelContext(try ModelContainerFactory.readOnly(at: url))
        #expect(try LedgerOperations.ledger(owner, context: reopened).name == "Renamed")
        #expect(try LedgerOperations.ledger(empty, context: reopened).name == "Empty")
        #expect(try reopened.fetchCount(.items(.all)) == 1)
        #expect(try reopened.fetchCount(.items(.all, ledgerIdentifier: owner)) == 1)
        #expect(
            try LedgerBalanceOperations.snapshot(context: reopened, ledgerIdentifier: owner).latestBalance
                == 20
        )
        #expect(!reopened.hasChanges)
    }

    @Test
    func externallySavedBalancesAreReadWithoutReconstructingHistory() throws {
        let container = try ModelContainerFactory.inMemory()
        let initial = ModelContext(container)
        let other = try LedgerOperations.create(context: initial, name: "Other")
        let standard = try makeItem(context: initial, owner: .default, income: 10)
        _ = try makeItem(context: initial, owner: other.id, income: 90)
        try initial.save()
        let external = ModelContext(container)
        let item = try #require(try ItemQueryOperations.item(context: external, persistentID: standard.id))
        try item.modify(
            values: .init(
                date: item.localDate,
                content: item.content,
                income: 30,
                outgo: 0,
                category: "Same",
                priority: 0
            ),
            repeatID: item.repeatID
        )
        item.modify(balance: 999)
        try external.save()
        let reader = ModelContext(container)
        #expect(try LedgerBalanceOperations.snapshot(context: reader).latestBalance == 999)
        #expect(
            try LedgerBalanceOperations.snapshot(context: reader, ledgerIdentifier: other.id).latestBalance
                == 90
        )
        #expect(!reader.hasChanges)
    }

    private func makeItem(context: ModelContext, owner: LedgerIdentifier, income: Decimal) throws -> Item {
        let item = try Item.create(
            context: context,
            values: .init(
                date: .now,
                content: "Same",
                income: income,
                outgo: 0,
                category: "Same",
                priority: 0,
                ledgerIdentifier: owner
            ),
            repeatID: UUID()
        )
        item.modify(balance: income)
        return item
    }
}
