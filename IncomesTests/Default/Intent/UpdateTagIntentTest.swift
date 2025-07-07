@testable import Incomes
import SwiftData
import Testing

@MainActor
struct UpdateTagIntentTest {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func perform() throws {
        let tag = try Tag.create(context: context, name: "name", type: .content)
        try UpdateTagIntent.perform(
            (
                context: context,
                tag: .init(tag)!,
                name: "new"
            )
        )
        let result = try #require(context.fetchFirst(.tags(.all)))
        #expect(result.name == "new")
    }

    @Test func performNotFound() throws {
        let entity = TagEntity(
            id: UUID().uuidString,
            name: "missing",
            typeID: TagType.content.rawValue
        )
        #expect(throws: Error.self) {
            try UpdateTagIntent.perform(
                (
                    context: context,
                    tag: entity,
                    name: "new"
                )
            )
        }
    }
}
