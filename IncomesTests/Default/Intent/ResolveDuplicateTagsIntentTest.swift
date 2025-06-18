@testable import Incomes
import SwiftData
import Testing

struct ResolveDuplicateTagsIntentTest {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func perform() throws {
        let tag1 = try Tag.createIgnoringDuplicates(context: context, name: "A", type: .year)
        _ = try Tag.createIgnoringDuplicates(context: context, name: "A", type: .year)
        _ = try Tag.createIgnoringDuplicates(context: context, name: "A", type: .year)
        let tag4 = try Tag.createIgnoringDuplicates(context: context, name: "B", type: .yearMonth)
        _ = try Tag.createIgnoringDuplicates(context: context, name: "B", type: .yearMonth)

        #expect(try context.fetchCount(.tags(.all)) == 5)

        try ResolveDuplicateTagsIntent.perform(
            (
                context: context,
                tags: [tag1, tag4].compactMap(TagEntity.init)
            )
        )

        #expect(try context.fetchCount(.tags(.all)) == 2)
    }
}
