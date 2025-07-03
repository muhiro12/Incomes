@testable import Incomes
import SwiftData
import Testing

@MainActor
struct GetHasDuplicateTagsIntentTest {
    let container: ModelContainer

    init() {
        container = testContainer
    }

    @Test func perform() throws {
        #expect(try GetHasDuplicateTagsIntent.perform(container) == false)

        let tag1 = try Tag.createIgnoringDuplicates(context: container.mainContext, name: "A", type: .year)
        _ = try Tag.createIgnoringDuplicates(context: container.mainContext, name: "A", type: .year)

        #expect(try GetHasDuplicateTagsIntent.perform(container) == true)

        try MergeDuplicateTagsIntent.perform(
            (
                container: container,
                tags: try container.mainContext.fetch(.tags(.isSameWith(tag1))).compactMap(TagEntity.init)
            )
        )

        #expect(try GetHasDuplicateTagsIntent.perform(container) == false)
    }
}
