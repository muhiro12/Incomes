import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct ItemServiceTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    // MARK: - Create

    @Test
    func create_creates_item() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-01-01T12:00:00Z"),
            content: "content",
            income: 200,
            outgo: 100,
            category: "category",
            repeatCount: 1
        )
        let result = try #require(fetchItems(context).first)
        #expect(result.utcDate == isoDate("2000-01-01T00:00:00Z"))
        #expect(result.content == "content")
        #expect(result.balance == 100)
    }

    @Test
    func create_creates_repeating_items() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-01-01T12:00:00Z"),
            content: "content",
            income: 200,
            outgo: 100,
            category: "category",
            repeatCount: 3
        )
        let items = fetchItems(context)
        #expect(items.count == 3)
        #expect(Set(items.map(\.repeatID)).count == 1)
    }

    // MARK: - Delete

    @Test
    func deleteAll_removes_all_items() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-01-01T12:00:00Z"),
            content: "contentA",
            income: 100,
            outgo: 0,
            category: "category",
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-01-02T12:00:00Z"),
            content: "contentB",
            income: 0,
            outgo: 50,
            category: "category",
            repeatCount: 1
        )
        #expect(fetchItems(context).count == 2)
        try ItemService.deleteAll(context: context)
        #expect(fetchItems(context).isEmpty)
    }

    @Test
    func deleteAll_when_empty_is_noop() throws {
        #expect(fetchItems(context).isEmpty)
        try ItemService.deleteAll(context: context)
        #expect(fetchItems(context).isEmpty)
    }

    @Test
    func delete_removes_item() throws {
        let item = try ItemService.create(
            context: context,
            date: shiftedDate("2000-01-01T12:00:00Z"),
            content: "content",
            income: 200,
            outgo: 100,
            category: "category",
            repeatCount: 1
        )
        #expect(!fetchItems(context).isEmpty)
        try ItemService.delete(context: context, item: item)
        #expect(fetchItems(context).isEmpty)
    }

    // MARK: - Counts

    @Test
    func allItemsCount_returns_count() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-01-01T12:00:00Z"),
            content: "content",
            income: 100,
            outgo: 0,
            category: "category",
            repeatCount: 1
        )
        let count = try ItemService.allItemsCount(context: context)
        #expect(count == 1)
    }

    @Test
    func repeatItemsCount_returns_count_for_repeat_id() throws {
        let item = try ItemService.create(
            context: context,
            date: shiftedDate("2000-01-01T12:00:00Z"),
            content: "A",
            income: 0,
            outgo: 100,
            category: "Test",
            repeatCount: 2
        )
        let count = try ItemService.repeatItemsCount(
            context: context,
            repeatID: item.repeatID
        )
        #expect(count == 2)
    }

    @Test
    func yearItemsCount_returns_count_for_year() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-02-01T12:00:00Z"),
            content: "A",
            income: 0,
            outgo: 100,
            category: "Test",
            repeatCount: 1
        )
        let count = try ItemService.yearItemsCount(
            context: context,
            date: shiftedDate("2000-01-02T00:00:00Z")
        )
        #expect(count == 1)
    }

    // MARK: - Fetch items

    @Test
    func items_returns_items_for_month() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-01-05T12:00:00Z"),
            content: "January",
            income: 100,
            outgo: 0,
            category: "Test",
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-02-10T12:00:00Z"),
            content: "February",
            income: 200,
            outgo: 0,
            category: "Test",
            repeatCount: 1
        )
        let januaryItems = try ItemService.items(
            context: context,
            date: shiftedDate("2000-01-15T00:00:00Z")
        )
        #expect(januaryItems.count == 1)
        #expect(januaryItems.first?.content == "January")

        let februaryItems = try ItemService.items(
            context: context,
            date: shiftedDate("2000-02-20T00:00:00Z")
        )
        #expect(februaryItems.count == 1)
        #expect(februaryItems.first?.content == "February")
    }

    @Test
    func items_returns_multiple_items_in_month() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-01-10T12:00:00Z"),
            content: "First",
            income: 0,
            outgo: 50,
            category: "Test",
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-01-20T12:00:00Z"),
            content: "Second",
            income: 0,
            outgo: 50,
            category: "Test",
            repeatCount: 1
        )
        let items = try ItemService.items(
            context: context,
            date: shiftedDate("2000-01-15T00:00:00Z")
        )
        #expect(items.count == 2)
        #expect(items.contains { item in
            item.content == "First"
        })
        #expect(items.contains { item in
            item.content == "Second"
        })
    }

    @Test
    func items_returns_descending_order() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-03-01T12:00:00Z"),
            content: "A",
            income: 10,
            outgo: 0,
            category: "Test",
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-03-10T12:00:00Z"),
            content: "B",
            income: 20,
            outgo: 0,
            category: "Test",
            repeatCount: 1
        )
        let items = try ItemService.items(
            context: context,
            date: shiftedDate("2000-03-15T00:00:00Z")
        )
        #expect(items.count == 2)
        #expect(items[0].content == "B")
        #expect(items[1].content == "A")
    }

    // MARK: - Next / Previous

    @Test
    func nextItemDate_returns_next_local_date() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-01-01T12:00:00Z"),
            content: "A",
            income: 0,
            outgo: 100,
            category: "Test",
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-02-01T12:00:00Z"),
            content: "B",
            income: 0,
            outgo: 100,
            category: "Test",
            repeatCount: 1
        )
        let result = try #require(
            try ItemService.nextItemDate(
                context: context,
                date: shiftedDate("2000-01-15T00:00:00Z")
            )
        )
        #expect(result == shiftedDate("2000-02-01T00:00:00Z"))
    }

    @Test
    func nextItemDate_returns_nil_when_not_found() throws {
        let result = try ItemService.nextItemDate(
            context: context,
            date: shiftedDate("2001-01-01T00:00:00Z")
        )
        #expect(result == nil)
    }

    @Test
    func nextItem_returns_next_item() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-01-01T12:00:00Z"),
            content: "A",
            income: 0,
            outgo: 100,
            category: "Test",
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-02-01T12:00:00Z"),
            content: "B",
            income: 0,
            outgo: 200,
            category: "Test",
            repeatCount: 1
        )
        let item = try #require(
            try ItemService.nextItem(
                context: context,
                date: shiftedDate("2000-01-15T00:00:00Z")
            )
        )
        #expect(item.content == "B")
    }

    @Test
    func nextItem_returns_item_when_date_is_exact() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-03-01T00:00:00Z"),
            content: "Exact",
            income: 10,
            outgo: 0,
            category: "Test",
            repeatCount: 1
        )
        let result = try ItemService.nextItem(
            context: context,
            date: shiftedDate("2000-03-01T00:00:00Z")
        )
        #expect(result?.content == "Exact")
    }

    @Test
    func nextItem_returns_nil_when_not_found() throws {
        let result = try ItemService.nextItem(
            context: context,
            date: shiftedDate("2001-01-01T00:00:00Z")
        )
        #expect(result == nil)
    }

    @Test
    func previousItemDate_returns_previous_local_date() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-01-01T12:00:00Z"),
            content: "A",
            income: 0,
            outgo: 100,
            category: "Test",
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-02-01T12:00:00Z"),
            content: "B",
            income: 0,
            outgo: 100,
            category: "Test",
            repeatCount: 1
        )
        let result = try #require(
            try ItemService.previousItemDate(
                context: context,
                date: shiftedDate("2000-02-15T00:00:00Z")
            )
        )
        #expect(result == shiftedDate("2000-02-01T00:00:00Z"))
    }

    @Test
    func previousItemDate_returns_nil_when_not_found() throws {
        let result = try ItemService.previousItemDate(
            context: context,
            date: shiftedDate("1999-01-01T00:00:00Z")
        )
        #expect(result == nil)
    }

    @Test
    func previousItem_returns_previous_item() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-01-01T12:00:00Z"),
            content: "A",
            income: 0,
            outgo: 100,
            category: "Test",
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-02-01T12:00:00Z"),
            content: "B",
            income: 0,
            outgo: 200,
            category: "Test",
            repeatCount: 1
        )
        let item = try #require(
            try ItemService.previousItem(
                context: context,
                date: shiftedDate("2000-02-15T00:00:00Z")
            )
        )
        #expect(item.content == "B")
    }

    @Test
    func previousItem_returns_nil_when_not_found() throws {
        let result = try ItemService.previousItem(
            context: context,
            date: shiftedDate("1999-01-01T00:00:00Z")
        )
        #expect(result == nil)
    }

    // MARK: - Update

    @Test
    func update_updates_single_item() throws {
        let item = try ItemService.create(
            context: context,
            date: shiftedDate("2000-01-01T12:00:00Z"),
            content: "content",
            income: 200,
            outgo: 100,
            category: "category",
            repeatCount: 1
        )
        try ItemService.update(
            context: context,
            item: item,
            date: shiftedDate("2001-01-02T12:00:00Z"),
            content: "content2",
            income: 100,
            outgo: 200,
            category: "category2"
        )
        let result = fetchItems(context).first!
        #expect(result.utcDate == isoDate("2001-01-02T00:00:00Z"))
        #expect(result.content == "content2")
        #expect(result.income == 100)
        #expect(result.outgo == 200)
        #expect(result.balance == -100)
    }

    @Test
    func update_updates_only_selected_repeating_item() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-01-01T12:00:00Z"),
            content: "content",
            income: 200,
            outgo: 100,
            category: "category",
            repeatCount: 3
        )
        try ItemService.update(
            context: context,
            item: fetchItems(context)[1],
            date: shiftedDate("2000-02-02T12:00:00Z"),
            content: "content2",
            income: 100,
            outgo: 200,
            category: "category2"
        )
        let first = fetchItems(context)[0]
        let second = fetchItems(context)[1]
        let last = fetchItems(context)[2]
        #expect(first.utcDate == isoDate("2000-03-01T00:00:00Z"))
        #expect(first.content == "content")
        #expect(first.income == 200)
        #expect(first.outgo == 100)
        #expect(first.balance == 100)
        #expect(second.utcDate == isoDate("2000-02-02T00:00:00Z"))
        #expect(second.content == "content2")
        #expect(second.income == 100)
        #expect(second.outgo == 200)
        #expect(second.balance == 0)
        #expect(last.utcDate == isoDate("2000-01-01T00:00:00Z"))
        #expect(last.content == "content")
        #expect(last.income == 200)
        #expect(last.outgo == 100)
        #expect(last.balance == 100)
    }

    @Test
    func updateAll_updates_all_repeating_items() throws {
        let item = try ItemService.create(
            context: context,
            date: shiftedDate("2000-01-01T12:00:00Z"),
            content: "content",
            income: 200,
            outgo: 100,
            category: "category",
            repeatCount: 1
        )
        try ItemService.updateAll(
            context: context,
            item: item,
            date: shiftedDate("2001-01-02T12:00:00Z"),
            content: "content2",
            income: 100,
            outgo: 200,
            category: "category2"
        )
        let result = fetchItems(context).first!
        #expect(result.utcDate == isoDate("2001-01-02T00:00:00Z"))
        #expect(result.content == "content2")
        #expect(result.income == 100)
        #expect(result.outgo == 200)
        #expect(result.balance == -100)
    }

    @Test
    func updateAll_updates_repeating_items_from_selected_item() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-01-01T12:00:00Z"),
            content: "content",
            income: 200,
            outgo: 100,
            category: "category",
            repeatCount: 3
        )
        try ItemService.updateAll(
            context: context,
            item: fetchItems(context)[1],
            date: shiftedDate("2000-02-02T12:00:00Z"),
            content: "content2",
            income: 100,
            outgo: 200,
            category: "category2"
        )
        let first = fetchItems(context)[0]
        let second = fetchItems(context)[1]
        let last = fetchItems(context)[2]
        #expect(first.utcDate == isoDate("2000-03-02T00:00:00Z"))
        #expect(first.content == "content2")
        #expect(first.income == 100)
        #expect(first.outgo == 200)
        #expect(first.balance == -300)
        #expect(second.utcDate == isoDate("2000-02-02T00:00:00Z"))
        #expect(second.content == "content2")
        #expect(second.income == 100)
        #expect(second.outgo == 200)
        #expect(second.balance == -200)
        #expect(last.utcDate == isoDate("2000-01-02T00:00:00Z"))
        #expect(last.content == "content2")
        #expect(last.income == 100)
        #expect(last.outgo == 200)
        #expect(last.balance == -100)
    }

    @Test
    func updateFuture_updates_all_future_repeating_items() throws {
        let item = try ItemService.create(
            context: context,
            date: shiftedDate("2000-01-01T12:00:00Z"),
            content: "content",
            income: 200,
            outgo: 100,
            category: "category",
            repeatCount: 1
        )
        try ItemService.updateFuture(
            context: context,
            item: item,
            date: shiftedDate("2001-01-02T12:00:00Z"),
            content: "content2",
            income: 100,
            outgo: 200,
            category: "category2"
        )
        let result = fetchItems(context).first!
        #expect(result.utcDate == isoDate("2001-01-02T00:00:00Z"))
        #expect(result.content == "content2")
        #expect(result.income == 100)
        #expect(result.outgo == 200)
        #expect(result.balance == -100)
    }

    @Test
    func updateFuture_updates_future_items_only() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-01-01T12:00:00Z"),
            content: "content",
            income: 200,
            outgo: 100,
            category: "category",
            repeatCount: 3
        )
        try ItemService.updateFuture(
            context: context,
            item: fetchItems(context)[1],
            date: shiftedDate("2000-02-02T12:00:00Z"),
            content: "content2",
            income: 100,
            outgo: 200,
            category: "category2"
        )
        let first = fetchItems(context)[0]
        let second = fetchItems(context)[1]
        let last = fetchItems(context)[2]
        #expect(first.utcDate == isoDate("2000-03-02T00:00:00Z"))
        #expect(first.content == "content2")
        #expect(first.income == 100)
        #expect(first.outgo == 200)
        #expect(first.balance == -100)
        #expect(second.utcDate == isoDate("2000-02-02T00:00:00Z"))
        #expect(second.content == "content2")
        #expect(second.income == 100)
        #expect(second.outgo == 200)
        #expect(second.balance == 0)
        #expect(last.utcDate == isoDate("2000-01-01T00:00:00Z"))
        #expect(last.content == "content")
        #expect(last.income == 200)
        #expect(last.outgo == 100)
        #expect(last.balance == 100)
    }

    // MARK: - Recalculate

    @Test
    func recalculate_recomputes_balance_after_update() throws {
        let item = try ItemService.create(
            context: context,
            date: shiftedDate("2000-01-01T00:00:00Z"),
            content: "content",
            income: 100,
            outgo: 50,
            category: "category",
            repeatCount: 1
        )
        try ItemService.update(
            context: context,
            item: item,
            date: item.localDate,
            content: item.content,
            income: item.income,
            outgo: 90,
            category: item.category?.name ?? ""
        )
        try ItemService.recalculate(
            context: context,
            date: shiftedDate("1999-12-01T00:00:00Z")
        )
        let result = try #require(fetchItems(context).first)
        #expect(result.balance == 10)
    }
}
