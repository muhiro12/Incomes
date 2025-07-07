import Foundation
@testable import Incomes
import SwiftData
import Testing

@MainActor
struct DeleteItemIntentTest {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func perform() throws {
        let item = try CreateItemIntent.perform(
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
        #expect(!fetchItems(context).isEmpty)
        try DeleteItemIntent.perform((context: context, item: item))
        #expect(fetchItems(context).isEmpty)
    }
}
