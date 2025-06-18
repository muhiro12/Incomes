@testable import Incomes
import SwiftData
import Testing

struct GetHasDuplicateTagsIntentTest {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func perform() throws {
        #expect(try GetHasDuplicateTagsIntent.perform(context) == false)

        let tag1 = try Tag.createIgnoringDuplicates(context: context, name: "A", type: .year)
        _ = try Tag.createIgnoringDuplicates(context: context, name: "A", type: .year)

        #expect(try GetHasDuplicateTagsIntent.perform(context) == true)

        try MergeDuplicateTagsIntent.perform(
            (
                context: context,
                tags: try context.fetch(.tags(.isSameWith(tag1))).compactMap(TagEntity.init)
            )
        )

        #expect(try GetHasDuplicateTagsIntent.perform(context) == false)
    }
}
