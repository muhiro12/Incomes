@testable import Incomes
import SwiftData
import Testing

struct RecalculateItemIntentTest {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func perform() throws {
        let entity = try CreateItemIntent.perform(
            (
                context: context,
                date: isoDate("2000-01-01T00:00:00Z"),
                content: "content",
                income: 100,
                outgo: 50,
                category: "category",
                repeatCount: 1
            )
        )
        try UpdateItemIntent.perform(
            (
                context: context,
                item: entity,
                date: entity.date,
                content: entity.content,
                income: entity.income,
                outgo: 90,
                category: entity.category ?? ""
            )
        )
        try RecalculateItemIntent.perform((context: context, date: isoDate("1999-12-01T00:00:00Z")))
        let item = try #require(fetchItems(context).first)
        #expect(item.balance == 10)
    }
}
