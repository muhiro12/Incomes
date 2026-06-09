import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct TagItemDeletionResolverTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func resolveItemsForDeletion_returns_items_from_selected_tags() throws {
        let firstItem = try Item.create(
            context: context,
            date: shiftedDate("2001-01-01T00:00:00Z"),
            content: "First",
            income: 0,
            outgo: 1,
            category: "Category",
            priority: 0,
            repeatID: .init()
        )
        let secondItem = try Item.create(
            context: context,
            date: shiftedDate("2001-02-01T00:00:00Z"),
            content: "Second",
            income: 0,
            outgo: 2,
            category: "Category",
            priority: 0,
            repeatID: .init()
        )

        let firstTag = try #require(
            firstItem.tags?.first { tag in
                tag.type == .yearMonth
            }
        )
        let secondTag = try #require(
            secondItem.tags?.first { tag in
                tag.type == .yearMonth
            }
        )

        let resolved = TagMutationOperations.resolveItemsForDeletion(
            from: [firstTag, secondTag],
            indices: IndexSet([1])
        )

        let resolvedIDs = Set(resolved.map(\.id))
        #expect(!resolvedIDs.contains(firstItem.id))
        #expect(resolvedIDs.contains(secondItem.id))
    }

    @Test
    func resolveTagsForDeletion_returns_selected_tags() throws {
        let firstTag = try Tag.create(context: context, name: "2001", type: .year)
        let secondTag = try Tag.create(context: context, name: "2002", type: .year)

        let resolved = TagMutationOperations.resolveTagsForDeletion(
            from: [firstTag, secondTag],
            indices: IndexSet([1])
        )

        #expect(resolved.count == 1)
        #expect(resolved.first?.id == secondTag.id)
    }

    @Test
    func resolveItemsForDeletion_returns_all_items_in_selected_year() throws {
        let januaryItem = try Item.create(
            context: context,
            date: shiftedDate("2001-01-01T00:00:00Z"),
            content: "January",
            income: 0,
            outgo: 1,
            category: "Category",
            priority: 0,
            repeatID: .init()
        )
        let februaryItem = try Item.create(
            context: context,
            date: shiftedDate("2001-02-01T00:00:00Z"),
            content: "February",
            income: 0,
            outgo: 2,
            category: "Category",
            priority: 0,
            repeatID: .init()
        )
        let marchItem = try Item.create(
            context: context,
            date: shiftedDate("2002-03-01T00:00:00Z"),
            content: "March",
            income: 0,
            outgo: 3,
            category: "Category",
            priority: 0,
            repeatID: .init()
        )

        let yearTags = try context.fetch(
            .tags(.typeIs(.year), order: .reverse)
        )

        let resolved = TagMutationOperations.resolveItemsForDeletion(
            from: yearTags,
            indices: IndexSet(integer: 1)
        )

        let resolvedIDs = Set(resolved.map(\.id))
        #expect(resolvedIDs.contains(januaryItem.id))
        #expect(resolvedIDs.contains(februaryItem.id))
        #expect(resolvedIDs.contains(marchItem.id) == false)
    }

    @Test
    func delete_items_resolved_from_year_tag_removes_only_selected_year() throws {
        _ = try Item.create(
            context: context,
            date: shiftedDate("2001-01-01T00:00:00Z"),
            content: "January",
            income: 0,
            outgo: 1,
            category: "Category",
            priority: 0,
            repeatID: .init()
        )
        _ = try Item.create(
            context: context,
            date: shiftedDate("2001-02-01T00:00:00Z"),
            content: "February",
            income: 0,
            outgo: 2,
            category: "Category",
            priority: 0,
            repeatID: .init()
        )
        let remainingItem = try Item.create(
            context: context,
            date: shiftedDate("2002-03-01T00:00:00Z"),
            content: "March",
            income: 0,
            outgo: 3,
            category: "Category",
            priority: 0,
            repeatID: .init()
        )

        let yearTags = try context.fetch(
            .tags(.typeIs(.year), order: .reverse)
        )
        let itemsToDelete = TagMutationOperations.resolveItemsForDeletion(
            from: yearTags,
            indices: IndexSet(integer: 1)
        )

        try ItemDeletionOperations.delete(
            context: context,
            items: itemsToDelete
        )

        let remainingIDs = Set(fetchItems(context).map(\.id))
        #expect(remainingIDs == [remainingItem.id])
        #expect(try context.fetchCount(.tags(.nameIs("2001", type: .year))) == 0)
        #expect(try context.fetchCount(.tags(.nameIs("200101", type: .yearMonth))) == 0)
        #expect(try context.fetchCount(.tags(.nameIs("200102", type: .yearMonth))) == 0)
        #expect(try context.fetchCount(.tags(.nameIs("2002", type: .year))) == 1)
    }
}
