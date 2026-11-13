import Foundation
import SwiftData
import Testing

@testable import IncomesLibrary

@MainActor
struct ItemRunningBalanceOrderTests {
    @Test
    func numbered_names_follow_display_order() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        try seed(context: context, contents: ["Entry 2", "Entry 10", "Entry 1"])
        let items = try context.fetch(.items(.all, order: .forward))
        #expect(items.map(\.content) == ["Entry 1", "Entry 2", "Entry 10"])
        #expect(items.map(\.balance) == [3, 4, 6])
        try assertRunningBalances(context: context)
    }

    @Test
    func mixed_case_and_accents_follow_display_order() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        try seed(context: context, contents: ["apple", "Banana", "Éclair", "Zebra"])
        try assertRunningBalances(context: context)
    }

    @Test
    func saved_identical_names_follow_native_identity_order_after_recalculation() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        try seed(context: context, contents: Array(repeating: "Same", count: 12), checkingEachSave: false)
        try ItemBalanceOperations.recalculateAndSave(context: context, date: .distantPast)
        try assertRunningBalances(context: context)
        try assertRunningBalances(context: ModelContext(context.container))
    }

    @Test
    func creating_identical_names_still_needs_a_durable_tie_breaker() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        try seed(context: context, contents: ["Same", "Same"], checkingEachSave: false)
        withKnownIssue("#420: temporary identifiers change the same-name order when creation is saved") {
            let items = try context.fetch(.items(.all, order: .forward))
            #expect(items.map(\.balance) == [1, 3])
        }
    }

    @Test
    func edits_and_reviews_use_the_displayed_sequence() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        try seed(context: context, contents: ["Entry 2", "Entry 10", "Entry 1"])
        let item = try #require(ItemQueryOperations.items(context: context).first { $0.content == "Entry 2" })
        let identifier = item.id
        let inputs: [ItemFormInput] = [
            input(content: "Entry 2", outgo: 10),
            input(content: "Entry 20", outgo: 10),
            input(content: "Entry 20", outgo: 10, priority: 5),
            input(content: "Entry 20", outgo: 10, day: "2020-01-11"),
            input(content: "Entry 20", outgo: 10, day: "2020-01-09")
        ]
        for (index, input) in inputs.enumerated() {
            let review = try ItemBalanceProjectionOperations.reviewUpdate(
                context: context, item: item, input: input, scope: .thisItem
            )
            if index == .zero {
                #expect(review.comparison.projected.minimumBalance == -7)
            }
            _ = try ItemUpdateOperations.updateAndSaveWithOutcome(
                context: context, item: item, input: input, review: review
            )
            let snapshot = try LedgerBalanceOperations.snapshot(context: context)
            #expect(review.comparison.projected.latestBalance == snapshot.latestBalance)
            #expect(item.id == identifier)
            try assertRunningBalances(context: context)
            try assertRunningBalances(context: ModelContext(context.container))
        }
    }

    @Test
    func disk_reopen_and_another_context_keep_order_and_balances() throws {
        let directory = try persistentTestDirectory(fileManager: .default)
        let url = directory.appendingPathComponent("Order.sqlite")
        do {
            let container = try ModelContainerFactory.make(configuration: .init(url: url, cloudKitDatabase: .none))
            let context = ModelContext(container)
            try seed(context: context, contents: Array(repeating: "Same", count: 12), checkingEachSave: false)
            try ItemBalanceOperations.recalculateAndSave(context: context, date: .distantPast)
            try assertRunningBalances(context: context)
        }
        let container = try ModelContainerFactory.make(configuration: .init(url: url, cloudKitDatabase: .none))
        try assertRunningBalances(context: ModelContext(container))
        let writer = ModelContext(container)
        let item = try #require(ItemQueryOperations.items(context: writer).first)
        _ = try ItemUpdateOperations.updateAndSaveWithOutcome(
            context: writer, item: item, input: input(content: "Same", outgo: 5), scope: .thisItem
        )
        try assertRunningBalances(context: ModelContext(container))
    }

    private func seed(context: ModelContext, contents: [String], checkingEachSave: Bool = true) throws {
        let date = shiftedDate("2020-01-10T12:00:00Z")
        for (index, content) in contents.enumerated() {
            _ = try ItemCreationOperations.createAndSaveWithOutcome(
                context: context,
                input: .init(
                    date: date,
                    content: content,
                    income: Decimal(index + 1),
                    outgo: 0,
                    category: "General",
                    priority: 0
                ),
                repeatMonthSelections: []
            )
            if checkingEachSave {
                try assertRunningBalances(context: context)
            }
        }
    }

    private func input(
        content: String, outgo: Decimal, priority: Int = 0, day: String = "2020-01-10"
    ) -> ItemFormInput {
        .init(
            date: shiftedDate("\(day)T12:00:00Z"),
            content: content,
            income: 0,
            outgo: outgo,
            category: "General",
            priority: priority
        )
    }

    private func assertRunningBalances(context: ModelContext) throws {
        let descriptor = ItemFetchDescriptor.items(.all, order: .forward)
        let items = descriptor.results(from: try context.fetch(descriptor.candidateDescriptor))
        #expect(items.map(\.id) == items.sorted(by: >).map(\.id))
        var balance = Decimal.zero
        for item in items {
            balance += item.income - item.outgo
            #expect(item.balance == balance, "\(item.content): \(item.id)")
        }
        let reverse = try ItemQueryOperations.items(context: context)
        #expect(reverse.map(\.id) == items.reversed().map(\.id))
    }
}
