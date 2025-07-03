@testable import Incomes
import SwiftData
import Testing

@MainActor
struct GetTagByIDIntentTest {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func perform() throws {
        let model = try Tag.create(context: context, name: "name", type: .content)
        let id = try model.id.base64Encoded()
        let tagEntity = try #require(
            try GetTagByIDIntent.perform(
                (
                    container: context.container,
                    id: id
                )
            )
        )
        #expect(tagEntity.name == "name")
        #expect(tagEntity.type == .content)
    }
}
