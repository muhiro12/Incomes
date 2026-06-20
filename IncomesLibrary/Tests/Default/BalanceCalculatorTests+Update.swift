import Foundation
@testable import IncomesLibrary
import Testing

extension BalanceCalculatorTests {
    struct UpdateTests {
        @Test("Result is as expected when updating")
        func updating_is_expected() throws {
            let context = testContext
            var items: [Item] = []
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
                items.append(item)
            }
            try BalanceCalculator.calculate(in: context, after: .distantPast)
            let item = items[1]
            try item.modify(
                values: .init(
                    date: shiftedDate("2000-02-01T12:00:00Z"),
                    content: "content",
                    income: 300,
                    outgo: 100,
                    category: "category",
                    priority: 0
                ),
                repeatID: UUID()
            )
            try BalanceCalculator.calculate(in: context, after: item.localDate)
            let first = try #require(fetchItems(context).first)
            let last = try #require(fetchItems(context).last)
            #expect(first.balance == 600)
            #expect(last.balance == 100)
        }

        @Test("Result is as expected when updating first")
        func updating_first_is_expected() throws {
            let context = testContext
            var items: [Item] = []
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
                items.append(item)
            }
            try BalanceCalculator.calculate(in: context, after: .distantPast)
            let item = items[0]
            try item.modify(
                values: .init(
                    date: shiftedDate("2000-01-01T12:00:00Z"),
                    content: "content",
                    income: 300,
                    outgo: 100,
                    category: "category",
                    priority: 0
                ),
                repeatID: UUID()
            )
            try BalanceCalculator.calculate(in: context, after: item.localDate)
            let first = try #require(fetchItems(context).first)
            let last = try #require(fetchItems(context).last)
            #expect(first.balance == 600)
            #expect(last.balance == 200)
        }

        @Test("Result is as expected when updating last")
        func updating_last_is_expected() throws {
            let context = testContext
            var items: [Item] = []
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
                items.append(item)
            }
            try BalanceCalculator.calculate(in: context, after: .distantPast)
            let item = items[4]
            try item.modify(
                values: .init(
                    date: shiftedDate("2000-05-01T12:00:00Z"),
                    content: "content",
                    income: 300,
                    outgo: 100,
                    category: "category",
                    priority: 0
                ),
                repeatID: UUID()
            )
            try BalanceCalculator.calculate(in: context, after: item.localDate)
            let first = try #require(fetchItems(context).first)
            let last = try #require(fetchItems(context).last)
            #expect(first.balance == 600)
            #expect(last.balance == 100)
        }

        @Test("Result is as expected when changing order")
        func changing_order_is_expected() throws {
            let context = testContext
            var items: [Item] = []
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
                items.append(item)
            }
            try BalanceCalculator.calculate(in: context, after: .distantPast)
            let item = items[4]
            try item.modify(
                values: .init(
                    date: shiftedDate("1999-12-31T00:00:00Z"),
                    content: "content",
                    income: 300,
                    outgo: 100,
                    category: "category",
                    priority: 0
                ),
                repeatID: UUID()
            )
            try BalanceCalculator.calculate(in: context, after: item.localDate)
            let first = try #require(fetchItems(context).first)
            let last = try #require(fetchItems(context).last)
            #expect(first.balance == 600)
            #expect(last.balance == 200)
        }
    }
}
