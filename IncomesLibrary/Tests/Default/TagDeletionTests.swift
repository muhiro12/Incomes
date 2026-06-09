import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct TagDeletionTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func delete_removes_unused_tag() throws {
        let tag = try Tag.create(context: context, name: "name", type: .year)
        #expect(try context.fetchCount(.tags(.all)) == 1)
        TagMutationOperations.delete(tag: tag)
        #expect(try context.fetchCount(.tags(.all)) == 0)
    }

    @Test
    func delete_does_not_remove_item_or_tag_when_tag_is_still_in_use() throws {
        let item = try Item.create(
            context: context,
            date: shiftedDate("2024-01-01T00:00:00Z"),
            content: "Coffee",
            income: .zero,
            outgo: 500,
            category: "Food",
            priority: 0,
            repeatID: .init()
        )
        let contentTag = try #require(
            item.tags?.first { tag in
                tag.type == .content
            }
        )

        TagMutationOperations.delete(tag: contentTag)

        #expect(try context.fetchCount(.items(.all)) == 1)
        #expect(try context.fetchCount(.tags(.nameIs("Coffee", type: .content))) == 1)
        let refreshedItem = try #require(
            try context.fetchFirst(.items(.idIs(item.id)))
        )
        #expect(refreshedItem.tags?.contains { tag in
            tag.type == .content && tag.name == "Coffee"
        } == true)
    }

    @Test
    func deleteAll_removes_all_tags() throws {
        _ = try Tag.create(context: context, name: "A", type: .content)
        _ = try Tag.create(context: context, name: "B", type: .content)
        #expect(try context.fetchCount(.tags(.all)) == 2)
        try TagMutationOperations.deleteAll(context: context)
        #expect(try context.fetchCount(.tags(.all)) == 0)
    }

    @Test
    func deleteAll_when_empty_is_noop() throws {
        #expect(try context.fetchCount(.tags(.all)) == 0)
        try TagMutationOperations.deleteAll(context: context)
        #expect(try context.fetchCount(.tags(.all)) == 0)
    }
}
