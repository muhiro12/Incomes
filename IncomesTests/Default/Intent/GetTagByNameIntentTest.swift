@testable import Incomes
import SwiftData
import Testing

struct GetTagByNameIntentTest {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func perform() throws {
        _ = try Tag.create(context: context, name: "name", type: .year)
        let tag = try #require(
            try GetTagByNameIntent.perform(
                (
                    context: context,
                    name: "name",
                    type: .year
                )
            )
        )
        #expect(tag.name == "name")
        #expect(tag.type == .year)
    }
}
