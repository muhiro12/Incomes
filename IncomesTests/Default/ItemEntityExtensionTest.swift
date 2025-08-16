@testable import Incomes
import SwiftData
import Testing

@MainActor
struct ItemEntityExtensionTest {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func modelFetch() throws {
        let item = try ItemService.create(
            context: context,
            date: isoDate("2000-01-01T12:00:00Z"),
            content: "content",
            income: 200,
            outgo: 100,
            category: "category",
            repeatCount: 1
        )
        #expect(item.content == "content")
        #expect(item.balance == 100)
    }
}
