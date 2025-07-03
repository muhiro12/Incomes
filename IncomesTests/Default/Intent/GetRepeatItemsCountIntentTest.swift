@testable import Incomes
import SwiftData
import Testing

@MainActor
struct GetRepeatItemsCountIntentTest {
    let container: ModelContainer

    init() {
        container = testContainer
    }

    @Test func perform() throws {
        let entity = try CreateItemIntent.perform(
            (
                container: container,
                date: isoDate("2000-01-01T12:00:00Z"),
                content: "A",
                income: 0,
                outgo: 100,
                category: "Test",
                repeatCount: 2
            )
        )
        let repeatID = try PersistentIdentifier(base64Encoded: entity.id)
        let model = try #require(try container.mainContext.fetchFirst(.items(.idIs(repeatID))))
        let count = try GetRepeatItemsCountIntent.perform(
            (container: container, repeatID: model.repeatID)
        )
        #expect(count == 2)
    }
}
