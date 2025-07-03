@testable import Incomes
import SwiftData
import Testing

@MainActor
struct GetTagByIDIntentTest {
    let container: ModelContainer

    init() {
        container = testContainer
    }

    @Test func perform() throws {
        let model = try Tag.create(container: container, name: "name", type: .content)
        let id = try model.id.base64Encoded()
        let tagEntity = try #require(
            try GetTagByIDIntent.perform(
                (
                    container: container,
                    id: id
                )
            )
        )
        #expect(tagEntity.name == "name")
        #expect(tagEntity.type == .content)
    }
}
