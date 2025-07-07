@testable import Incomes
import SwiftData
import Testing

@MainActor
struct GetAllItemsCountIntentTest {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func perform() throws {
        _ = try CreateItemIntent.perform(
            (
                context: context,
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "content",
                income: 100,
                outgo: 0,
                category: "category",
                repeatCount: 1
            )
        )
        let count = try GetAllItemsCountIntent.perform(context)
        #expect(count == 1)
    }
}
