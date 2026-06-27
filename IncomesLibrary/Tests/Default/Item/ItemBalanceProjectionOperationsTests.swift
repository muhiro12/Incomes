import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

@Suite(.serialized)
struct ItemBalanceProjectionOperationsTests {
    private struct ItemProjectionTestState: Equatable {
        let utcDate: Date
        let content: String
        let income: Decimal
        let outgo: Decimal
        let balance: Decimal
    }

    private struct MonthKey: Hashable {
        let year: Int
        let month: Int
    }

    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func previewCreate_does_not_mutate_items_and_reports_negative_balance() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "Income",
                income: 100,
                outgo: 0,
                category: "category",
                priority: 0
            )
        )
        let beforeState = try itemStates(context)

        let input = ItemFormInput(
            date: shiftedDate("2000-02-01T12:00:00Z"),
            content: "Rent",
            income: 0,
            outgo: 250,
            category: "category",
            priority: 0
        )
        let projection = try ItemBalanceProjectionOperations.previewCreate(
            context: context,
            input: input,
            repeatMonthSelections: []
        )

        #expect(try itemStates(context) == beforeState)
        #expect(projection.changedItemCount == 1)
        #expect(projection.minimumBalance == -150)
        #expect(projection.hasNegativeBalance)
        #expect(projection.monthlyBalances.map(\.balance) == [-150])
        let firstNegativeDate = try #require(projection.firstNegativeDate)
        #expect(Calendar.current.isDate(firstNegativeDate, inSameDayAs: input.date))
    }

    @Test
    func previewUpdateFuture_matches_actual_balances_without_pre_mutating() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "content",
                income: 200,
                outgo: 100,
                category: "category",
                priority: 0
            ),
            repeatCount: 3
        )
        let target = fetchItems(context)[1]
        let input = ItemFormInput(
            date: shiftedDate("2000-02-02T12:00:00Z"),
            content: "content2",
            income: 100,
            outgo: 200,
            category: "category2",
            priority: 0
        )
        let beforeState = try itemStates(context)

        let projection = try ItemBalanceProjectionOperations.previewUpdate(
            context: context,
            item: target,
            input: input,
            scope: .futureItems
        )

        #expect(try itemStates(context) == beforeState)

        try updateFutureItems(
            context: context,
            item: target,
            input: input
        )

        let affectedDateRange = try #require(projection.affectedDateRange)
        let actualMonthlyBalances = try monthlyBalances(
            context: context,
            from: affectedDateRange.lowerBound
        )
        #expect(projection.monthlyBalances == actualMonthlyBalances)
        #expect(projection.minimumBalance == -100)
    }

    @Test
    func previewUpdateAll_matches_actual_balances_without_pre_mutating() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "content",
                income: 200,
                outgo: 100,
                category: "category",
                priority: 0
            ),
            repeatCount: 3
        )
        let target = fetchItems(context)[1]
        let input = ItemFormInput(
            date: shiftedDate("2000-02-02T12:00:00Z"),
            content: "content2",
            income: 100,
            outgo: 200,
            category: "category2",
            priority: 0
        )
        let beforeState = try itemStates(context)

        let projection = try ItemBalanceProjectionOperations.previewUpdate(
            context: context,
            item: target,
            input: input,
            scope: .allItems
        )

        #expect(try itemStates(context) == beforeState)

        try updateAllItems(
            context: context,
            item: target,
            input: input
        )

        let affectedDateRange = try #require(projection.affectedDateRange)
        let actualMonthlyBalances = try monthlyBalances(
            context: context,
            from: affectedDateRange.lowerBound
        )
        #expect(projection.monthlyBalances == actualMonthlyBalances)
        #expect(projection.minimumBalance == -300)
    }

    private func itemStates(
        _ context: ModelContext
    ) throws -> [ItemProjectionTestState] {
        let items = try context.fetch(.items(.all, order: .forward))
        return items.map { item in
            .init(
                utcDate: item.utcDate,
                content: item.content,
                income: item.income,
                outgo: item.outgo,
                balance: item.balance
            )
        }
    }

    private func monthlyBalances(
        context: ModelContext,
        from date: Date
    ) throws -> [ItemBalanceProjectionOperations.MonthlyBalance] {
        let calendar = Calendar.current
        let fetchedItems = try context.fetch(
            .items(.all, order: .forward)
        )
        let items = fetchedItems.filter { item in
            item.localDate >= date
        }
        var balancesByMonth = [MonthKey: ItemBalanceProjectionOperations.MonthlyBalance]()
        var orderedKeys = [MonthKey]()
        items.forEach { item in
            let key: MonthKey = .init(
                year: calendar.component(.year, from: item.localDate),
                month: calendar.component(.month, from: item.localDate)
            )
            if balancesByMonth[key] == nil {
                orderedKeys.append(key)
            }
            balancesByMonth[key] = .init(
                monthDate: calendar.startOfMonth(for: item.localDate),
                balance: item.balance
            )
        }
        return orderedKeys.compactMap { key in
            balancesByMonth[key]
        }
    }
}
