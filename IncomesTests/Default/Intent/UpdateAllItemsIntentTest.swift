@testable import Incomes
import SwiftData
import Testing

@MainActor
struct UpdateAllItemsIntentTest {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test @MainActor func perform() throws {
        let item = try CreateItemIntent.perform(
            (
                context: context,
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "content",
                income: 200,
                outgo: 100,
                category: "category",
                repeatCount: 1
            )
        )
        try UpdateAllItemsIntent.perform(
            (
                context: context,
                item: item,
                date: shiftedDate("2001-01-02T12:00:00Z"),
                content: "content2",
                income: 100,
                outgo: 200,
                category: "category2"
            )
        )
        let result = fetchItems(context).first!
        #expect(result.utcDate == isoDate("2001-01-02T00:00:00Z"))
        #expect(result.content == "content2")
        #expect(result.income == 100)
        #expect(result.outgo == 200)
        #expect(result.balance == -100)
    }

    @Test func performRepeat() throws {
        _ = try CreateItemIntent.perform(
            (
                context: context,
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "content",
                income: 200,
                outgo: 100,
                category: "category",
                repeatCount: 3
            )
        )
        try UpdateAllItemsIntent.perform(
            (
                context: context,
                item: ItemEntity(fetchItems(context)[1])!,
                date: shiftedDate("2000-02-02T12:00:00Z"),
                content: "content2",
                income: 100,
                outgo: 200,
                category: "category2"
            )
        )
        let first = fetchItems(context)[0]
        let second = fetchItems(context)[1]
        let last = fetchItems(context)[2]

        #expect(first.utcDate == isoDate("2000-03-02T00:00:00Z"))
        #expect(first.content == "content2")
        #expect(first.income == 100)
        #expect(first.outgo == 200)
        #expect(first.balance == -300)

        #expect(second.utcDate == isoDate("2000-02-02T00:00:00Z"))
        #expect(second.content == "content2")
        #expect(second.income == 100)
        #expect(second.outgo == 200)
        #expect(second.balance == -200)

        #expect(last.utcDate == isoDate("2000-01-02T00:00:00Z"))
        #expect(last.content == "content2")
        #expect(last.income == 100)
        #expect(last.outgo == 200)
        #expect(last.balance == -100)
    }
}
