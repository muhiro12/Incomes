@testable import Incomes
import SwiftData
import Testing

@MainActor
struct MergeDuplicateTagsIntentTest {
    let container: ModelContainer

    init() {
        container = testContainer
    }

    @Test func mergeWhenTagsAreDifferent() throws {
        let item1 = try Item.create(
            container: container,
            date: .now,
            content: "contentA",
            income: .zero,
            outgo: .zero,
            category: "",
            repeatID: .init()
        )
        let item2 = try Item.create(
            container: container,
            date: .now,
            content: "contentB",
            income: .zero,
            outgo: .zero,
            category: "",
            repeatID: .init()
        )
        let item3 = try Item.create(
            container: container,
            date: .now,
            content: "contentC",
            income: .zero,
            outgo: .zero,
            category: "",
            repeatID: .init()
        )
        let tag1 = item1.tags!.first {
            $0.type == .content
        }!
        let tag2 = item2.tags!.first {
            $0.type == .content
        }!
        let tag3 = item3.tags!.first {
            $0.type == .content
        }!

        try MergeDuplicateTagsIntent.perform(
            (
                container: container,
                tags: [tag1, tag2, tag3].compactMap(TagEntity.init)
            )
        )

        #expect(try container.mainContext.fetchCount(.tags(.nameIs("contentA", type: .content))) == 1)
        #expect(try container.mainContext.fetchCount(.tags(.nameIs("contentB", type: .content))) == 0)
        #expect(try container.mainContext.fetchCount(.tags(.nameIs("contentC", type: .content))) == 0)
        #expect(item1.tags?.contains(tag1) == true)
        #expect(item2.tags?.contains(tag1) == true)
        #expect(item3.tags?.contains(tag1) == true)
    }

    @Test func mergeWhenTagsAreDuplicated() throws {
        let tag1 = try Tag.createIgnoringDuplicates(container: container, name: "contentA", type: .content)
        let tag2 = try Tag.createIgnoringDuplicates(container: container, name: "contentA", type: .content)
        let tag3 = try Tag.createIgnoringDuplicates(container: container, name: "contentA", type: .content)

        try MergeDuplicateTagsIntent.perform(
            (
                container: container,
                tags: [tag1, tag2, tag3].compactMap(TagEntity.init)
            )
        )

        #expect(try container.mainContext.fetchCount(.tags(.nameIs("contentA", type: .content))) == 1)
    }
}
