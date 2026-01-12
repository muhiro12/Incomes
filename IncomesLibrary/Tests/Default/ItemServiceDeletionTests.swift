import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct ItemServiceDeletionTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func resolveItemsForDeletion_returns_selected_items() throws {
        let firstItem = try Item.create(
            context: context,
            date: shiftedDate("2001-01-01T00:00:00Z"),
            content: "A",
            income: 0,
            outgo: 10,
            category: "Category",
            repeatID: .init()
        )
        let secondItem = try Item.create(
            context: context,
            date: shiftedDate("2001-02-01T00:00:00Z"),
            content: "B",
            income: 0,
            outgo: 20,
            category: "Category",
            repeatID: .init()
        )
        let thirdItem = try Item.create(
            context: context,
            date: shiftedDate("2001-03-01T00:00:00Z"),
            content: "C",
            income: 0,
            outgo: 30,
            category: "Category",
            repeatID: .init()
        )

        let resolved = ItemService.resolveItemsForDeletion(
            from: [firstItem, secondItem, thirdItem],
            indices: IndexSet([0, 2])
        )

        #expect(resolved.map(\.id) == [firstItem.id, thirdItem.id])
    }

    @Test
    func delete_removes_all_provided_items() throws {
        let firstItem = try Item.create(
            context: context,
            date: shiftedDate("2001-01-01T00:00:00Z"),
            content: "A",
            income: 0,
            outgo: 10,
            category: "Category",
            repeatID: .init()
        )
        let secondItem = try Item.create(
            context: context,
            date: shiftedDate("2001-02-01T00:00:00Z"),
            content: "B",
            income: 0,
            outgo: 20,
            category: "Category",
            repeatID: .init()
        )

        try ItemService.delete(
            context: context,
            items: [firstItem, secondItem]
        )

        #expect(fetchItems(context).isEmpty)
    }
}
