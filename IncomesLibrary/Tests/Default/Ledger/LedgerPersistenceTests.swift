import Foundation
import SwiftData
import Testing

@testable import IncomesLibrary

@MainActor
struct LedgerPersistenceTests {
    @Test
    func reopenedReadOnlyStoreKeepsRenamedAndEmptyBooksWithoutAnOwnershipColumn() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
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
    func externallySavedAmountsAreDerivedIndependentlyOfTheStoredBalanceCache() throws {
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
        #expect(try LedgerBalanceOperations.snapshot(context: reader).latestBalance == 30)
        #expect(
            try LedgerBalanceOperations.snapshot(context: reader, ledgerIdentifier: other.id).latestBalance
                == 90
        )
        #expect(!reader.hasChanges)
    }

    private func makeItem(context: ModelContext, owner: LedgerIdentifier, income: Decimal) throws -> Item {
        try Item.create(
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
    }
}
