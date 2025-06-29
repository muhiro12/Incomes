@testable import Incomes
import SwiftData
import Testing

struct GetPreviousItemIntentTest {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func perform() throws {
        _ = try CreateItemIntent.perform(
            (
                context: context,
                date: isoDate("2000-01-01T12:00:00Z"),
                content: "A",
                income: 0,
                outgo: 100,
                category: "Test",
                repeatCount: 1
            )
        )
        _ = try CreateItemIntent.perform(
            (
                context: context,
                date: isoDate("2000-02-01T12:00:00Z"),
                content: "B",
                income: 0,
                outgo: 200,
                category: "Test",
                repeatCount: 1
            )
        )
        let item = try #require(try GetPreviousItemIntent.perform((context: context, date: isoDate("2000-02-15T00:00:00Z"))))
        #expect(item.content == "B")
    }
}
