@testable import Incomes
import SwiftData
import Testing

@MainActor
struct CreateItemIntentTest {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func perform() throws {
        _ = try CreateItemIntent.perform(
            (
                context: context,
                date: isoDate("2000-01-01T12:00:00Z"),
                content: "content",
                income: 200,
                outgo: 100,
                category: "category",
                repeatCount: 1
            )
        )
        let result = fetchItems(context).first!
        #expect(result.utcDate == isoDate("2000-01-01T00:00:00Z"))
        #expect(result.content == "content")
        #expect(result.balance == 100)
    }

    @Test func performRepeat() throws {
        _ = try CreateItemIntent.perform(
            (
                context: context,
                date: isoDate("2000-01-01T12:00:00Z"),
                content: "content",
                income: 200,
                outgo: 100,
                category: "category",
                repeatCount: 3
            )
        )
        let items = fetchItems(context)
        #expect(items.count == 3)
        #expect(Set(items.map(\.repeatID)).count == 1)
    }
}
