@testable import Incomes
import SwiftData
import Testing

@MainActor
struct GetAllItemsCountIntentTest {
    let container: ModelContainer

    init() {
        container = testContainer
    }

    @Test func perform() throws {
        _ = try CreateItemIntent.perform(
            (
                container: container,
                date: isoDate("2000-01-01T12:00:00Z"),
                content: "content",
                income: 100,
                outgo: 0,
                category: "category",
                repeatCount: 1
            )
        )
        let count = try GetAllItemsCountIntent.perform(container)
        #expect(count == 1)
    }
}
