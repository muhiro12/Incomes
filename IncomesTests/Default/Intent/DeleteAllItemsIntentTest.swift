@testable import Incomes
import SwiftData
import Testing

@MainActor
struct DeleteAllItemsIntentTest {
    let container: ModelContainer

    init() {
        container = testContainer
    }

    @Test func perform() throws {
        _ = try CreateItemIntent.perform(
            (
                container: container,
                date: isoDate("2000-01-01T12:00:00Z"),
                content: "contentA",
                income: 100,
                outgo: 0,
                category: "category",
                repeatCount: 1
            )
        )
        _ = try CreateItemIntent.perform(
            (
                container: container,
                date: isoDate("2000-01-02T12:00:00Z"),
                content: "contentB",
                income: 0,
                outgo: 50,
                category: "category",
                repeatCount: 1
            )
        )
        #expect(fetchItems(container).count == 2)
        try DeleteAllItemsIntent.perform(container)
        #expect(fetchItems(container).isEmpty)
    }
}
