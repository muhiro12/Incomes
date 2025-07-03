@testable import Incomes
import SwiftData
import Testing

@MainActor
struct DeleteItemIntentTest {
    let container: ModelContainer

    init() {
        container = testContainer
    }

    @Test func perform() throws {
        let item = try CreateItemIntent.perform(
            (
                container: container,
                date: isoDate("2000-01-01T12:00:00Z"),
                content: "content",
                income: 200,
                outgo: 100,
                category: "category",
                repeatCount: 1
            )
        )
        #expect(!fetchItems(container).isEmpty)
        try DeleteItemIntent.perform((container: container, item: item))
        #expect(fetchItems(container).isEmpty)
    }
}
