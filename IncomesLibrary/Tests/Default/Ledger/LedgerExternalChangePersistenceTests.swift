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
                (10_157, 20_223)
            case .update:
                (10_170, 20_220)
            case .delete:
                (10_140, 20_120)
            }
        }
    }

    @Test(arguments: Change.allCases)
    func separate_writer_commits_scoped_balances_and_reopening_never_repairs_history(change: Change) throws {
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
            return try balances(context)
        }
        try autoreleasepool {
            let context = ModelContext(try container(at: url))
            for _ in 0..<3 {
                try verifyRead(context, change: change, owner: owners.additional)
            }
            #expect(try balances(context) == saved)
            #expect(try LedgerOperations.ledger(owners.empty, context: context).name == "Empty")
            #expect(!context.hasChanges)
        }
    }
}

private extension LedgerExternalChangePersistenceTests {
    enum Fixture {
        static let standardOffset: Decimal = 10_000
        static let additionalOffset: Decimal = 20_000
        static let anchorIncome: Decimal = 100
        static let standardIncome: Decimal = 10
        static let additionalIncome: Decimal = 90
        static let standardTailIncome: Decimal = 40
        static let additionalTailIncome: Decimal = 20
        static let standardInsertedIncome: Decimal = 7
        static let additionalInsertedIncome: Decimal = 13
        static let standardUpdatedIncome: Decimal = 30
        static let additionalUpdatedIncome: Decimal = 100
        static let anchorDay = 1
        static let targetDay = 2
        static let insertedDay = 3
        static let tailDay = 4
    }

    func seed(at url: URL) throws -> (additional: LedgerIdentifier, empty: LedgerIdentifier) {
        let context = ModelContext(try container(at: url))
        let owner = try LedgerOperations.create(context: context, name: "Additional").id
        let empty = try LedgerOperations.create(context: context, name: "Empty").id
        let books = [(LedgerIdentifier.default, Fixture.standardOffset), (owner, Fixture.additionalOffset)]
        for (identifier, offset) in books {
            let anchor = try makeItem(
                context, owner: identifier, day: Fixture.anchorDay, content: "Anchor", income: Fixture.anchorIncome
            )
            let target = try makeItem(
                context,
                owner: identifier,
                day: Fixture.targetDay,
                content: "Target",
                income: identifier == .default ? Fixture.standardIncome : Fixture.additionalIncome
            )
            let tail = try makeItem(
                context,
                owner: identifier,
                day: Fixture.tailDay,
                content: "Tail",
                income: identifier == .default ? Fixture.standardTailIncome : Fixture.additionalTailIncome
            )
            anchor.modify(balance: offset + Fixture.anchorIncome)
            target.modify(balance: offset + Fixture.anchorIncome + target.income)
            tail.modify(balance: target.balance + tail.income)
        }
        try context.save()
        return (owner, empty)
    }

    func apply(_ change: Change, at url: URL, owner: LedgerIdentifier) throws {
        let context = ModelContext(try container(at: url))
        for identifier in [LedgerIdentifier.default, owner] {
            let target = try #require(try context.fetch(.items(.all, ledgerIdentifier: identifier)).first { item in
                item.content == "Target"
            })
            switch change {
            case .insert:
                _ = try ItemCreationOperations.createAndSaveWithOutcome(
                    context: context,
                    input: input(
                        owner: identifier,
                        day: Fixture.insertedDay,
                        content: "Inserted",
                        income: identifier == .default
                            ? Fixture.standardInsertedIncome : Fixture.additionalInsertedIncome
                    ),
                    repeatMonthSelections: []
                )
            case .update:
                _ = try ItemUpdateOperations.updateAndSaveWithOutcome(
                    context: context,
                    item: target,
                    input: input(
                        owner: identifier,
                        day: Fixture.targetDay,
                        content: "Target",
                        income: identifier == .default ? Fixture.standardUpdatedIncome : Fixture.additionalUpdatedIncome
                    ),
                    scope: .thisItem
                )
            case .delete:
                _ = try ItemDeletionOperations.deleteAndSaveWithOutcome(context: context, item: target)
            }
            #expect(!context.hasChanges)
        }
    }

    func verifyRead(_ context: ModelContext, change: Change, owner: LedgerIdentifier) throws {
        #expect(try LedgerBalanceOperations.snapshot(context: context).latestBalance == change.expected.standard)
        #expect(
            try LedgerBalanceOperations.snapshot(context: context, ledgerIdentifier: owner).latestBalance
                == change.expected.additional
        )
        for (identifier, balance) in [
            (LedgerIdentifier.default, Fixture.standardOffset + Fixture.anchorIncome),
            (owner, Fixture.additionalOffset + Fixture.anchorIncome)
        ] {
            let anchor = try #require(try context.fetch(.items(.all, ledgerIdentifier: identifier)).first { item in
                item.content == "Anchor"
            })
            #expect(anchor.income == 100)
            #expect(anchor.balance == balance)
        }
        #expect(!context.hasChanges)
    }

    func input(owner: LedgerIdentifier, day: Int, content: String, income: Decimal) -> ItemFormInput {
        .init(
            date: shiftedDate("2000-01-0\(day)T12:00:00Z"),
            content: content,
            income: income,
            outgo: 0,
            category: "Shared",
            priority: 0,
            ledgerIdentifier: owner
        )
    }

    func makeItem(
        _ context: ModelContext, owner: LedgerIdentifier, day: Int, content: String, income: Decimal
    ) throws -> Item {
        try Item.create(
            context: context,
            values: .init(formInput: input(owner: owner, day: day, content: content, income: income)),
            repeatID: UUID()
        )
    }

    func balances(_ context: ModelContext) throws -> [String: Decimal] {
        try Dictionary(uniqueKeysWithValues: context.fetch(.allLedgerItems()).map { item in
            (try PersistentIdentifierCoder.encode(item.id), item.balance)
        })
    }

    func container(at url: URL) throws -> ModelContainer {
        try ModelContainerFactory.make(configuration: .init(url: url, cloudKitDatabase: .none))
    }
}
