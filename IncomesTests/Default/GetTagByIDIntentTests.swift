@testable import Incomes
import SwiftData
import Testing

struct GetTagByIDIntentTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func perform() throws {
        let model = try Tag.create(context: context, name: "name", type: .content)
        let id = try #require(model.id.base64Encoded())
        let tag = try #require(
            GetTagByIDIntent.perform(
                (
                    context: context,
                    id: try .init(base64Encoded: id)
                )
            )
        )
        #expect(tag.name == "name")
        #expect(tag.type == .content)
    }
}
