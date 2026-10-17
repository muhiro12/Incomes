import Foundation
import SwiftData
import Testing

@testable import IncomesLibrary

@MainActor
struct LedgerExternalChangePersistenceTests {
    enum Change: CaseIterable {
        case insert
        case update
        case delete

        var expected: (standard: Decimal, additional: Decimal) {
            switch self {
            case .insert:
                (57, 103)
            case .update:
                (70, 100)
            case .delete:
                (40, 0)
            }
        }
    }

    private static let standardIncome: Decimal = 10
    private static let retainedIncome: Decimal = 40
    private static let additionalIncome: Decimal = 90
    private static let insertedStandardIncome: Decimal = 7
    private static let insertedAdditionalIncome: Decimal = 13
    private static let updatedStandardIncome: Decimal = 30
    private static let updatedAdditionalIncome: Decimal = 100
    private static let incorrectBalance: Decimal = 999

    @Test(arguments: Change.allCases)
    func external_changes_reopen_with_independent_balances_and_idempotent_cache_repair(
        change: Change
    ) throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("Incomes.sqlite")
        let owners = try autoreleasepool {
            try seed(at: url)
        }
        try autoreleasepool {
            try apply(change, at: url, owner: owners.additional)
        }
        let saved = try autoreleasepool {
            let context = ModelContext(try container(at: url))
            try verifyRead(context, change: change, owner: owners.additional)
            let before = try archive(context)
            try ItemBalanceOperations.reconcileAndSave(context: context)
            #expect(!context.hasChanges)
            #expect(try archive(context) == before)
            return try cache(context)
        }
        try autoreleasepool {
            let context = ModelContext(try container(at: url))
            try verifyRead(context, change: change, owner: owners.additional)
            let currentCache = try cache(context)
            #expect(currentCache == saved)
            #expect(try LedgerOperations.ledger(owners.empty, context: context).name == "Empty")
            try ItemBalanceOperations.reconcileAndSave(context: context)
            #expect(!context.hasChanges)
            let repeatedCache = try cache(context)
            #expect(repeatedCache == saved)
            try verifyCache(context, owner: .default)
            try verifyCache(context, owner: owners.additional)
        }
    }
}

private extension LedgerExternalChangePersistenceTests {
    func seed(at url: URL) throws -> (
        additional: LedgerIdentifier, empty: LedgerIdentifier
    ) {
        let context = ModelContext(try container(at: url))
        let owner = try LedgerOperations.create(context: context, name: "Additional").id
        let empty = try LedgerOperations.create(context: context, name: "Empty").id
        _ = try makeItem(context, owner: .default, content: "Target", income: Self.standardIncome)
        _ = try makeItem(context, owner: .default, content: "Keep", income: Self.retainedIncome)
        _ = try makeItem(context, owner: owner, content: "Target", income: Self.additionalIncome)
        try context.save()
        return (owner, empty)
    }

    func apply(_ change: Change, at url: URL, owner: LedgerIdentifier) throws {
        let context = ModelContext(try container(at: url))
        let standard = try #require(try context.fetch(.items(.all)).first { $0.content == "Target" })
        let additional = try #require(try context.fetch(.items(.all, ledgerIdentifier: owner)).first)
        switch change {
        case .insert:
            _ = try makeItem(context, owner: .default, content: "Inserted", income: Self.insertedStandardIncome)
            _ = try makeItem(context, owner: owner, content: "Inserted", income: Self.insertedAdditionalIncome)
        case .update:
            try modify(standard, income: Self.updatedStandardIncome)
            try modify(additional, income: Self.updatedAdditionalIncome)
        case .delete:
            context.delete(standard)
            context.delete(additional)
        }
        for item in try context.fetch(.allLedgerItems()) {
            item.modify(balance: Self.incorrectBalance)
        }
        try context.save()
    }

    func modify(_ item: Item, income: Decimal) throws {
        try item.modify(
            values: .init(
                date: item.localDate,
                content: item.content,
                income: income,
                outgo: 0,
                category: "Shared",
                priority: 0,
                ledgerIdentifier: item.ledgerIdentifier
            ),
            repeatID: item.repeatID
        )
    }

    func verifyRead(
        _ context: ModelContext,
        change: Change,
        owner: LedgerIdentifier
    ) throws {
        #expect(
            try LedgerBalanceOperations.snapshot(context: context).latestBalance
                == change.expected.standard
        )
        #expect(
            try LedgerBalanceOperations.snapshot(context: context, ledgerIdentifier: owner).latestBalance
                == change.expected.additional
        )
        #expect(!context.hasChanges)
    }

    func verifyCache(_ context: ModelContext, owner: LedgerIdentifier) throws {
        let snapshot = try LedgerBalanceOperations.snapshot(context: context, ledgerIdentifier: owner)
        for item in try context.fetch(.items(.all, ledgerIdentifier: owner)) {
            #expect(item.balance == snapshot.balances[item.id])
        }
    }

    func makeItem(
        _ context: ModelContext,
        owner: LedgerIdentifier,
        content: String,
        income: Decimal
    ) throws -> Item {
        try Item.create(
            context: context,
            values: .init(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: content,
                income: income,
                outgo: 0,
                category: "Shared",
                priority: 0,
                ledgerIdentifier: owner
            ),
            repeatID: UUID()
        )
    }

    func archive(_ context: ModelContext) throws -> [IncomesFileItem] {
        try ItemExportOperations.fileItems(items: context.fetch(.allLedgerItems()))
    }

    func cache(_ context: ModelContext) throws -> [String: Decimal] {
        try Dictionary(
            uniqueKeysWithValues: context.fetch(.allLedgerItems()).map { item in
                (try PersistentIdentifierCoder.encode(item.id), item.balance)
            }
        )
    }

    func container(at url: URL) throws -> ModelContainer {
        try ModelContainerFactory.make(configuration: .init(url: url, cloudKitDatabase: .none))
    }
}
