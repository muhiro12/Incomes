@testable import Incomes
import SwiftData
import Testing

@MainActor
struct ResolveDuplicateTagsIntentTest {
    let container: ModelContainer

    init() {
        container = testContainer
    }

    @Test func perform() throws {
        let tag1 = try Tag.createIgnoringDuplicates(context: container.mainContext, name: "A", type: .year)
        _ = try Tag.createIgnoringDuplicates(context: container.mainContext, name: "A", type: .year)
        _ = try Tag.createIgnoringDuplicates(context: container.mainContext, name: "A", type: .year)
        let tag4 = try Tag.createIgnoringDuplicates(context: container.mainContext, name: "B", type: .yearMonth)
        _ = try Tag.createIgnoringDuplicates(context: container.mainContext, name: "B", type: .yearMonth)

        #expect(try container.mainContext.fetchCount(.tags(.all)) == 5)

        try ResolveDuplicateTagsIntent.perform(
            (
                container: container,
                tags: [tag1, tag4].compactMap(TagEntity.init)
            )
        )

        #expect(try container.mainContext.fetchCount(.tags(.all)) == 2)
    }
}
