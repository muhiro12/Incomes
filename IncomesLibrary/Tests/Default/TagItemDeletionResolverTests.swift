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
            repeatID: .init()
        )
        let secondItem = try Item.create(
            context: context,
            date: shiftedDate("2001-02-01T00:00:00Z"),
            content: "Second",
            income: 0,
            outgo: 2,
            category: "Category",
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

        let resolved = TagService.resolveItemsForDeletion(
            from: [firstTag, secondTag],
            indices: IndexSet([1])
        )

        let resolvedIDs = Set(resolved.map(\.id))
        #expect(!resolvedIDs.contains(firstItem.id))
        #expect(resolvedIDs.contains(secondItem.id))
    }
}
