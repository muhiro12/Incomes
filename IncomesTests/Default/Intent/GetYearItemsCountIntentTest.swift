@testable import Incomes
import SwiftData
import Testing

@MainActor
struct GetYearItemsCountIntentTest {
    let container: ModelContainer

    init() {
        container = testContainer
    }

    @Test func perform() throws {
        _ = try CreateItemIntent.perform(
            (
                container: container,
                date: isoDate("2000-02-01T12:00:00Z"),
                content: "A",
                income: 0,
                outgo: 100,
                category: "Test",
                repeatCount: 1
            )
        )
        let count = try GetYearItemsCountIntent.perform(
            (container: container, date: isoDate("2000-01-01T00:00:00Z"))
        )
        #expect(count == 1)
    }
}
