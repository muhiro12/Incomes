import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct TagOrphanTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func orphanTags_returns_unused_tags_for_all_types() throws {
        _ = Tag.createIgnoringDuplicates(context: context, name: "2030", type: .year)
        _ = Tag.createIgnoringDuplicates(context: context, name: "203001", type: .yearMonth)
        _ = Tag.createIgnoringDuplicates(context: context, name: "Unused Content", type: .content)
        _ = Tag.createIgnoringDuplicates(context: context, name: "Unused Category", type: .category)
        _ = Tag.createIgnoringDuplicates(context: context, name: "Unused Debug", type: .debug)
        let item = try Item.create(
            context: context,
            date: .now,
            content: "Used Content",
            income: .zero,
            outgo: .zero,
            category: "Used Category",
            priority: 0,
            repeatID: .init()
        )
        let attachedDebugTag = Tag.createIgnoringDuplicates(
            context: context,
            name: "Attached Debug",
            type: .debug
        )
        item.modify(tags: item.tags.orEmpty + [attachedDebugTag])

        let orphanTags = try TagOperations.orphanTags(context: context)

        #expect(orphanTags.count == 5)
        #expect(orphanTags.contains { tag in
            tag.type == .year && tag.name == "2030"
        })
        #expect(orphanTags.contains { tag in
            tag.type == .yearMonth && tag.name == "203001"
        })
        #expect(orphanTags.contains { tag in
            tag.type == .content && tag.name == "Unused Content"
        })
        #expect(orphanTags.contains { tag in
            tag.type == .category && tag.name == "Unused Category"
        })
        #expect(orphanTags.contains { tag in
            tag.type == .debug && tag.name == "Unused Debug"
        })
        #expect(orphanTags.contains { tag in
            tag.name == "Attached Debug"
        } == false)
    }

    @Test
    func isOrphan_returns_false_for_attached_tag() throws {
        let item = try Item.create(
            context: context,
            date: .now,
            content: "Used Content",
            income: .zero,
            outgo: .zero,
            category: "Used Category",
            priority: 0,
            repeatID: .init()
        )
        let contentTag = try #require(item.tags?.first { tag in
            tag.type == .content
        })

        #expect(TagOperations.isOrphan(tag: contentTag) == false)
    }

    @Test
    func isOrphan_returns_true_for_unused_tag() {
        let tag = Tag.createIgnoringDuplicates(
            context: context,
            name: "Unused Content",
            type: .content
        )

        #expect(TagOperations.isOrphan(tag: tag))
    }

    @Test
    func isOrphan_returns_true_after_relation_is_removed_and_saved() throws {
        let item = try Item.create(
            context: context,
            date: .now,
            content: "Used Content",
            income: .zero,
            outgo: .zero,
            category: "Used Category",
            priority: 0,
            repeatID: .init()
        )
        let debugTag = Tag.createIgnoringDuplicates(
            context: context,
            name: "Attached Debug",
            type: .debug
        )
        item.modify(tags: item.tags.orEmpty + [debugTag])

        try context.save()

        item.modify(tags: item.tags.orEmpty.filter { tag in
            tag.id != debugTag.id
        })

        try context.save()

        #expect(TagOperations.isOrphan(tag: debugTag))
    }

    @Test
    func deleteAllOrphanTags_removes_only_unused_tags() throws {
        let item = try Item.create(
            context: context,
            date: .now,
            content: "Used Content",
            income: .zero,
            outgo: .zero,
            category: "Used Category",
            priority: 0,
            repeatID: .init()
        )
        let attachedDebugTag = Tag.createIgnoringDuplicates(
            context: context,
            name: "Attached Debug",
            type: .debug
        )
        item.modify(tags: item.tags.orEmpty + [attachedDebugTag])
        _ = Tag.createIgnoringDuplicates(
            context: context,
            name: "Unused Content",
            type: .content
        )
        _ = Tag.createIgnoringDuplicates(
            context: context,
            name: "Unused Debug",
            type: .debug
        )

        try TagOperations.deleteAllOrphanTags(context: context)

        #expect(try context.fetchCount(.tags(.nameIs("Unused Content", type: .content))) == 0)
        #expect(try context.fetchCount(.tags(.nameIs("Unused Debug", type: .debug))) == 0)
        #expect(try context.fetchCount(.tags(.nameIs("Used Content", type: .content))) == 1)
        #expect(try context.fetchCount(.tags(.nameIs("Attached Debug", type: .debug))) == 1)
    }
}
