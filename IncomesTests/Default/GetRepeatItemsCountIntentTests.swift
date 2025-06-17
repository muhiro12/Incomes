@testable import Incomes
import SwiftData
import Testing

struct GetRepeatItemsCountIntentTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func perform() throws {
        let entity = try CreateItemIntent.perform(
            (
                context: context,
                date: isoDate("2000-01-01T12:00:00Z"),
                content: "A",
                income: 0,
                outgo: 100,
                category: "Test",
                repeatCount: 2
            )
        )
        let repeatID = try PersistentIdentifier(base64Encoded: entity.id)
        let model = try #require(context.fetchFirst(.items(.idIs(repeatID))))
        let count = try GetRepeatItemsCountIntent.perform(
            (context: context, repeatID: model.repeatID)
        )
        #expect(count == 2)
    }
}
