import Foundation
@testable import IncomesLibrary
import Testing

extension BalanceCalculatorTests {
    struct InsertionTests {
        @Test("Result is as expected when inserting")
        func inserting_is_expected() throws {
            let context = testContext
            for month in 1...5 {
                let item = try Item.create(
                    context: context,
                    values: .init(
                        date: shiftedDate("2000-0\(month)-01T12:00:00Z"),
                        content: "content",
                        income: 200,
                        outgo: 100,
                        category: "category",
                        priority: 0
                    ),
                    repeatID: UUID()
                )
                context.insert(item)
            }
            try BalanceCalculator.calculate(in: context, after: .distantPast)
            let item = try Item.create(
                context: context,
                values: .init(
                    date: shiftedDate("2000-01-31T12:00:00Z"),
                    content: "content",
                    income: 200,
                    outgo: 100,
                    category: "category",
                    priority: 0
                ),
                repeatID: UUID()
            )
            context.insert(item)
            try BalanceCalculator.calculate(in: context, after: item.localDate)

            let first = try #require(fetchItems(context).first)
            let last = try #require(fetchItems(context).last)
            #expect(first.balance == 600)
            #expect(last.balance == 100)
        }

        @Test("Result is as expected when inserting first")
        func inserting_first_is_expected() throws {
            let context = testContext
            for month in 1...5 {
                let item = try Item.create(
                    context: context,
                    values: .init(
                        date: shiftedDate("2000-0\(month)-01T12:00:00Z"),
                        content: "content",
                        income: 200,
                        outgo: 100,
                        category: "category",
                        priority: 0
                    ),
                    repeatID: UUID()
                )
                context.insert(item)
            }
            try BalanceCalculator.calculate(in: context, after: .distantPast)
            let item = try Item.create(
                context: context,
                values: .init(
                    date: shiftedDate("2001-01-01T00:00:00Z"),
                    content: "content",
                    income: 200,
                    outgo: 100,
                    category: "category",
                    priority: 0
                ),
                repeatID: UUID()
            )
            context.insert(item)
            try BalanceCalculator.calculate(in: context, after: item.localDate)

            let first = try #require(fetchItems(context).first)
            let last = try #require(fetchItems(context).last)
            #expect(first.balance == 600)
            #expect(last.balance == 100)
        }

        @Test("Result is as expected when inserting last")
        func inserting_last_is_expected() throws {
            let context = testContext
            for month in 1...5 {
                let item = try Item.create(
                    context: context,
                    values: .init(
                        date: shiftedDate("2000-0\(month)-01T12:00:00Z"),
                        content: "content",
                        income: 200,
                        outgo: 100,
                        category: "category",
                        priority: 0
                    ),
                    repeatID: UUID()
                )
                context.insert(item)
            }
            try BalanceCalculator.calculate(in: context, after: .distantPast)
            let item = try Item.create(
                context: context,
                values: .init(
                    date: shiftedDate("2000-01-01T00:00:00Z"),
                    content: "content",
                    income: 200,
                    outgo: 100,
                    category: "category",
                    priority: 0
                ),
                repeatID: UUID()
            )
            context.insert(item)
            try BalanceCalculator.calculate(in: context, after: item.localDate)

            let first = try #require(fetchItems(context).first)
            let last = try #require(fetchItems(context).last)
            #expect(first.balance == 600)
            #expect(last.balance == 100)
        }

        @Test("Result is as expected when priorities share the same date")
        func priority_order_is_expected() throws {
            let context = testContext
            let baseDate = shiftedDate("2000-01-01T12:00:00Z")
            let lowPriorityItem = try Item.create(
                context: context,
                values: .init(
                    date: baseDate,
                    content: "Low",
                    income: 0,
                    outgo: 50,
                    category: "category",
                    priority: 0
                ),
                repeatID: UUID()
            )
            let highPriorityItem = try Item.create(
                context: context,
                values: .init(
                    date: baseDate,
                    content: "High",
                    income: 100,
                    outgo: 0,
                    category: "category",
                    priority: 10
                ),
                repeatID: UUID()
            )
            context.insert(lowPriorityItem)
            context.insert(highPriorityItem)

            try BalanceCalculator.calculate(in: context, after: .distantPast)

            let items = try context.fetch(.items(.all, order: .forward))
            #expect(items.count == 2)
            #expect(items[0].priority == 10)
            #expect(items[0].balance == 100)
            #expect(items[1].priority == 0)
            #expect(items[1].balance == 50)
        }
    }
}
