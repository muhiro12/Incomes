@testable import Incomes
import SwiftData
import Testing

@MainActor
struct ItemEntityExtensionTest {
    let container: ModelContainer

    init() {
        container = testContainer
    }

    @Test func modelFetch() throws {
        let entity = try CreateItemIntent.perform(
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
        let item = try entity.model(in: container.mainContext)
        #expect(item.content == "content")
        #expect(item.balance == 100)
    }
}
