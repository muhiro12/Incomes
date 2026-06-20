import Foundation
@testable import IncomesLibrary
import Testing

extension ItemOperationsTests {
    // MARK: - Delete

    @Test
    func deleteAll_removes_all_items() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "contentA",
                income: 100,
                outgo: 0,
                category: "category",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-02T12:00:00Z"),
                content: "contentB",
                income: 0,
                outgo: 50,
                category: "category",
                priority: 0
            ),
            repeatCount: 1
        )
        #expect(fetchItems(context).count == 2)
        try ItemDeletionOperations.deleteAll(context: context)
        #expect(fetchItems(context).isEmpty)
    }

    @Test
    func deleteAll_when_empty_is_noop() throws {
        #expect(fetchItems(context).isEmpty)
        try ItemDeletionOperations.deleteAll(context: context)
        #expect(fetchItems(context).isEmpty)
    }

    @Test
    func delete_removes_item() throws {
        let item = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "content",
                income: 200,
                outgo: 100,
                category: "category",
                priority: 0
            ),
            repeatCount: 1
        )
        #expect(!fetchItems(context).isEmpty)
        try ItemDeletionOperations.delete(context: context, item: item)
        #expect(fetchItems(context).isEmpty)
    }

    // MARK: - Counts

    @Test
    func allItemsCount_returns_count() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "content",
                income: 100,
                outgo: 0,
                category: "category",
                priority: 0
            ),
            repeatCount: 1
        )
        let count = try ItemQueryOperations.allItemsCount(context: context)
        #expect(count == 1)
    }

    @Test
    func repeatItemsCount_returns_count_for_repeat_id() throws {
        let item = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "A",
                income: 0,
                outgo: 100,
                category: "Test",
                priority: 0
            ),
            repeatCount: 2
        )
        let count = try ItemQueryOperations.repeatItemsCount(
            context: context,
            repeatID: item.repeatID
        )
        #expect(count == 2)
    }

    @Test
    func yearItemsCount_returns_count_for_year() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-02-01T12:00:00Z"),
                content: "A",
                income: 0,
                outgo: 100,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        let count = try ItemQueryOperations.yearItemsCount(
            context: context,
            date: shiftedDate("2000-01-02T00:00:00Z")
        )
        #expect(count == 1)
    }
}
