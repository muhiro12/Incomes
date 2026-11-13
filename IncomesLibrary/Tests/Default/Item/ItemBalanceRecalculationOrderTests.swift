import Foundation
import SwiftData
import Testing

@testable import IncomesLibrary

@MainActor
struct ItemBalanceRecalculationOrderTests {
    @Test
    func manual_recalculation_repairs_saved_rows_without_changing_facts_or_other_books() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let items = try seed(context: context)
        let facts = items.map { IncomesFileItem(item: $0) }
        let identifiers = items.map(\.id)
        let date = shiftedDate("2020-01-10T12:00:00Z")

        for _ in 0..<2 {
            try ItemBalanceOperations.recalculateAndSave(context: context, date: date)
            try assertRepairedSequence(context: context)
            #expect(items.map { IncomesFileItem(item: $0) } == facts)
            #expect(items.map(\.id) == identifiers)
            #expect(!context.hasChanges)
        }
        try assertRepairedSequence(context: ModelContext(context.container))
    }

    @Test
    func recalculation_after_another_context_changes_the_order_uses_the_current_sequence() throws {
        let container = try ModelContainerFactory.inMemory()
        let writer = ModelContext(container)
        let items = try seed(context: writer)
        let target = try #require(items.first { $0.content == "Entry 1" })
        let date = target.localDate
        try ItemBalanceOperations.recalculateAndSave(context: writer, date: date)
        try target.modify(
            values: .init(
                date: date,
                content: "Entry 30",
                income: target.income,
                outgo: target.outgo,
                category: "General",
                priority: target.priority
            ),
            repeatID: target.repeatID
        )
        try writer.save()

        let reader = ModelContext(container)
        let before = try reader.fetch(.items(.dateIsSameDayAs(date), order: .forward))
        #expect(before.prefix(4).map(\.content) == ["Priority", "Entry 2", "Entry 10", "Entry 30"])
        #expect(before.prefix(4).map(\.balance) == [1_006, 1_010, 1_012, 1_009])
        try ItemBalanceOperations.recalculateAndSave(context: reader, date: date)
        let after = try reader.fetch(.items(.dateIsSameDayAs(date), order: .forward))
        #expect(after.map(\.id) == before.map(\.id))
        #expect(after.prefix(4).map(\.balance) == [1_006, 1_007, 1_009, 1_012])
        try assertRunningBalances(context: ModelContext(container))
    }
}

private extension ItemBalanceRecalculationOrderTests {
    enum Amounts {
        static let baselineIncome: Decimal = 9
        static let entryTwoIncome: Decimal = 1
        static let entryTenIncome: Decimal = 2
        static let entryOneIncome: Decimal = 3
        static let equalIncome: Decimal = 4
        static let equalOutgo: Decimal = 5
        static let priorityIncome: Decimal = 6
        static let tailIncome: Decimal = 7
        static let otherIncome: Decimal = 999
        static let baseline: Decimal = 1_000
        static let otherBalance: Decimal = 777
        static let stale: Decimal = -1_234
        static let priority = 10
        static let afterPriority: Decimal = 1_006
        static let afterEntryOne: Decimal = 1_009
        static let afterEntryTwo: Decimal = 1_010
        static let afterEntryTen: Decimal = 1_012
        static let repairedPrefix = [baseline, afterPriority, afterEntryOne, afterEntryTwo, afterEntryTen]
        static let repairedTail: Decimal = 1_018
    }

    func seed(context: ModelContext) throws -> [Item] {
        let otherOwner = try LedgerOperations.create(context: context, name: "Other").id
        let inputs: [ItemFormInput] = [
            input(content: "Baseline", income: Amounts.baselineIncome, day: "2020-01-01"),
            input(content: "Entry 2", income: Amounts.entryTwoIncome),
            input(content: "Entry 10", income: Amounts.entryTenIncome),
            input(content: "Entry 1", income: Amounts.entryOneIncome),
            input(content: "Equal", income: Amounts.equalIncome),
            input(content: "Equal", income: .zero, outgo: Amounts.equalOutgo),
            input(content: "Priority", income: Amounts.priorityIncome, priority: Amounts.priority),
            input(content: "Tail", income: Amounts.tailIncome, day: "2020-01-11"),
            input(content: "Other", income: Amounts.otherIncome, owner: otherOwner)
        ]
        let items = try inputs.map { input in
            try Item.create(context: context, values: .init(formInput: input), repeatID: UUID())
        }
        for item in items {
            let balance = item.content == "Baseline" ? Amounts.baseline
                : item.content == "Other" ? Amounts.otherBalance : Amounts.stale
            item.modify(balance: balance)
        }
        try context.save()
        return items
    }

    func input(
        content: String,
        income: Decimal,
        outgo: Decimal = .zero,
        priority: Int = .zero,
        day: String = "2020-01-10",
        owner: LedgerIdentifier = .default
    ) -> ItemFormInput {
        .init(
            date: shiftedDate("\(day)T12:00:00Z"),
            content: content,
            income: income,
            outgo: outgo,
            category: "General",
            priority: priority,
            ledgerIdentifier: owner
        )
    }

    func assertRepairedSequence(context: ModelContext) throws {
        let items = try context.fetch(.items(.all, order: .forward))
        #expect(items.map(\.content) == [
            "Baseline", "Priority", "Entry 1", "Entry 2", "Entry 10", "Equal", "Equal", "Tail"
        ])
        #expect(items.prefix(Amounts.repairedPrefix.count).map(\.balance) == Amounts.repairedPrefix)
        #expect(items.last?.balance == Amounts.repairedTail)
        try assertRunningBalances(context: context)
    }

    func assertRunningBalances(context: ModelContext) throws {
        let descriptor = ItemFetchDescriptor.items(.all, order: .forward)
        let displayed = descriptor.results(from: try context.fetch(descriptor.candidateDescriptor))
        var balance = Amounts.baseline
        for item in displayed.dropFirst() {
            balance += item.income - item.outgo
            #expect(item.balance == balance)
        }
        #expect(displayed.first?.balance == Amounts.baseline)
        #expect(try ItemQueryOperations.items(context: context).map(\.id) == displayed.reversed().map(\.id))
        #expect(try context.fetch(.defaultLedgerItems(.all, order: .forward)).map(\.id) == displayed.map(\.id))
        let inventory = try context.fetch(.allLedgerItems(order: .forward))
        #expect(inventory.map(\.id) == inventory.sorted(by: >).map(\.id))
        #expect(inventory.first { $0.content == "Other" }?.balance == Amounts.otherBalance)
    }
}
