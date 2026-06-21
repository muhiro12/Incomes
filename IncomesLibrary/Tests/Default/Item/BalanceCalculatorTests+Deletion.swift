import Foundation
@testable import IncomesLibrary
import Testing

extension BalanceCalculatorTests {
    struct DeletionTests {
        @Test("Result is as expected when deleting")
        func deleting_is_expected() throws {
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
            context.delete(item)
            try BalanceCalculator.calculate(in: context, after: item.localDate)
            let first = try #require(fetchItems(context).first)
            let last = try #require(fetchItems(context).last)
            #expect(first.balance == 400)
            #expect(last.balance == 100)
        }

        @Test("Result is as expected when deleting first")
        func deleting_first_is_expected() throws {
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
            context.delete(item)
            try BalanceCalculator.calculate(in: context, after: item.localDate)
            let first = try #require(fetchItems(context).first)
            let last = try #require(fetchItems(context).last)
            #expect(first.balance == 400)
            #expect(last.balance == 100)
        }

        @Test("Result is as expected when deleting last")
        func deleting_last_is_expected() throws {
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
            context.delete(item)
            try BalanceCalculator.calculate(in: context, after: item.localDate)
            let first = try #require(fetchItems(context).first)
            let last = try #require(fetchItems(context).last)
            #expect(first.balance == 400)
            #expect(last.balance == 100)
        }
    }
}
