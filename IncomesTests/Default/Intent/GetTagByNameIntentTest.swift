@testable import Incomes
import SwiftData
import Testing

@MainActor
struct GetTagByNameIntentTest {
    let container: ModelContainer

    init() {
        container = testContainer
    }

    @Test func perform() throws {
        _ = try Tag.create(container: container, name: "name", type: .year)
        let tag = try #require(
            try GetTagByNameIntent.perform(
                (
                    container: container,
                    name: "name",
                    type: .year
                )
            )
        )
        #expect(tag.name == "name")
        #expect(tag.type == .year)
    }
}
