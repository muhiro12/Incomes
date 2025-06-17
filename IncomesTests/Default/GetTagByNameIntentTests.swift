@testable import Incomes
import SwiftData
import Testing

struct GetTagByNameIntentTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func perform() throws {
        _ = try Tag.create(context: context, name: "name", type: .year)
        let tag = try #require(
            GetTagByNameIntent.perform(
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
