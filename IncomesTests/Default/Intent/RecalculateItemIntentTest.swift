@testable import Incomes
import SwiftData
import Testing

@MainActor
struct RecalculateItemIntentTest {
    let container: ModelContainer

    init() {
        container = testContainer
    }

    @Test func perform() throws {
        let entity = try CreateItemIntent.perform(
            (
                container: container,
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
                container: container,
                item: entity,
                date: entity.date,
                content: entity.content,
                income: entity.income,
                outgo: 90,
                category: entity.category ?? ""
            )
        )
        try RecalculateItemIntent.perform((container: container, date: isoDate("1999-12-01T00:00:00Z")))
        let item = try #require(fetchItems(container).first)
        #expect(item.balance == 10)
    }
}
