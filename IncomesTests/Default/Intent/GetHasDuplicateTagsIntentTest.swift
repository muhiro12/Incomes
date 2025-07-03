@testable import Incomes
import SwiftData
import Testing

@MainActor
struct GetHasDuplicateTagsIntentTest {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func perform() throws {
        #expect(try GetHasDuplicateTagsIntent.perform(context.container) == false)

        let tag1 = try Tag.createIgnoringDuplicates(context: context, name: "A", type: .year)
        _ = try Tag.createIgnoringDuplicates(context: context, name: "A", type: .year)

        #expect(try GetHasDuplicateTagsIntent.perform(context.container) == true)

        try MergeDuplicateTagsIntent.perform(
            (
                container: context.container,
                tags: try context.fetch(.tags(.isSameWith(tag1))).compactMap(TagEntity.init)
            )
        )

        #expect(try GetHasDuplicateTagsIntent.perform(context.container) == false)
    }
}
