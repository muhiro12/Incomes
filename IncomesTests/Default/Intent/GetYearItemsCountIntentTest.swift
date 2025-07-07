@testable import Incomes
import SwiftData
import Testing

@MainActor
struct GetYearItemsCountIntentTest {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func perform() throws {
        _ = try CreateItemIntent.perform(
            (
                context: context,
                date: isoDate("2000-02-01T12:00:00Z"),
                content: "A",
                income: 0,
                outgo: 100,
                category: "Test",
                repeatCount: 1
            )
        )
        let count = try GetYearItemsCountIntent.perform(
            (context: context, date: isoDate("2000-01-01T00:00:00Z"))
        )
        #expect(count == 1)
    }
}
