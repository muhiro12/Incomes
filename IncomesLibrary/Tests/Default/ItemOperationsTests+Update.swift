// Update scenarios use literal fixture values to keep balance expectations readable.
// swiftlint:disable no_magic_numbers

import Foundation
@testable import IncomesLibrary
import Testing

extension ItemOperationsTests {
    // MARK: - Update

    @Test
    func update_updates_single_item() throws {
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
        try updateItem(
            context: context,
            item: item,
            input: .init(
                date: shiftedDate("2001-01-02T12:00:00Z"),
                content: "content2",
                income: 100,
                outgo: 200,
                category: "category2",
                priority: 0
            )
        )
        let result = try #require(fetchItems(context).first)
        #expect(result.utcDate == isoDate("2001-01-02T00:00:00Z"))
        #expect(result.content == "content2")
        #expect(result.income == 100)
        #expect(result.outgo == 200)
        #expect(result.balance == -100)
    }

    @Test
    func update_recalculates_balances_when_date_moves_later() throws {
        let originalTimeZone = TimeZone.ReferenceType.default
        TimeZone.ReferenceType.default = try #require(TimeZone(secondsFromGMT: 0))
        defer {
            TimeZone.ReferenceType.default = originalTimeZone
        }

        let itemToMove = try seedDateMoveLaterItems()
        try moveItemLater(itemToMove)
        try assertDateMoveLaterBalances()
    }

    func seedDateMoveLaterItems() throws -> Item {
        _ = try createDateMoveLaterItem(
            date: "2000-01-01T12:00:00Z",
            content: "First",
            income: 100,
            outgo: 0
        )
        let itemToMove = try createDateMoveLaterItem(
            date: "2000-01-02T12:00:00Z",
            content: "Second",
            income: 0,
            outgo: 50
        )
        _ = try createDateMoveLaterItem(
            date: "2000-01-03T12:00:00Z",
            content: "Third",
            income: 10,
            outgo: 0
        )
        return itemToMove
    }

    func createDateMoveLaterItem(
        date: String,
        content: String,
        income: Decimal,
        outgo: Decimal
    ) throws -> Item {
        try createItem(
            context: context,
            input: .init(
                date: shiftedDate(date),
                content: content,
                income: income,
                outgo: outgo,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
    }

    func moveItemLater(_ item: Item) throws {
        try updateItem(
            context: context,
            item: item,
            input: .init(
                date: shiftedDate("2000-01-04T12:00:00Z"),
                content: "Second",
                income: 0,
                outgo: 50,
                category: "Test",
                priority: 0
            )
        )
    }

    func assertDateMoveLaterBalances() throws {
        let items = try context.fetch(.items(.all, order: .forward))
        #expect(items.count == 3)
        #expect(items[0].utcDate == isoDate("2000-01-01T00:00:00Z"))
        #expect(items[1].utcDate == isoDate("2000-01-03T00:00:00Z"))
        #expect(items[2].utcDate == isoDate("2000-01-04T00:00:00Z"))
        #expect(items[0].balance == 100)
        #expect(items[1].balance == 110)
        #expect(items[2].balance == 60)
    }

    @Test
    func update_updates_only_selected_repeating_item() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "content",
                income: 200,
                outgo: 100,
                category: "category",
                priority: 0
            ),
            repeatCount: 3
        )
        try updateItem(
            context: context,
            item: fetchItems(context)[1],
            input: .init(
                date: shiftedDate("2000-02-02T12:00:00Z"),
                content: "content2",
                income: 100,
                outgo: 200,
                category: "category2",
                priority: 0
            )
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
        try updateItem(
            context: context,
            item: item,
            input: .init(
                date: shiftedDate("2001-01-02T12:00:00Z"),
                content: "content2",
                income: 100,
                outgo: 200,
                category: "category2",
                priority: 0
            ),
            scope: .allItems
        )
        let result = try #require(fetchItems(context).first)
        #expect(result.utcDate == isoDate("2001-01-02T00:00:00Z"))
        #expect(result.content == "content2")
        #expect(result.income == 100)
        #expect(result.outgo == 200)
        #expect(result.balance == -100)
    }

    @Test
    func updateAll_updates_repeating_items_from_selected_item() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "content",
                income: 200,
                outgo: 100,
                category: "category",
                priority: 0
            ),
            repeatCount: 3
        )
        try updateItem(
            context: context,
            item: fetchItems(context)[1],
            input: .init(
                date: shiftedDate("2000-02-02T12:00:00Z"),
                content: "content2",
                income: 100,
                outgo: 200,
                category: "category2",
                priority: 0
            ),
            scope: .allItems
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
        try updateItem(
            context: context,
            item: item,
            input: .init(
                date: shiftedDate("2001-01-02T12:00:00Z"),
                content: "content2",
                income: 100,
                outgo: 200,
                category: "category2",
                priority: 0
            ),
            scope: .futureItems
        )
        let result = try #require(fetchItems(context).first)
        #expect(result.utcDate == isoDate("2001-01-02T00:00:00Z"))
        #expect(result.content == "content2")
        #expect(result.income == 100)
        #expect(result.outgo == 200)
        #expect(result.balance == -100)
    }

    @Test
    func updateFuture_updates_future_items_only() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "content",
                income: 200,
                outgo: 100,
                category: "category",
                priority: 0
            ),
            repeatCount: 3
        )
        try updateItem(
            context: context,
            item: fetchItems(context)[1],
            input: .init(
                date: shiftedDate("2000-02-02T12:00:00Z"),
                content: "content2",
                income: 100,
                outgo: 200,
                category: "category2",
                priority: 0
            ),
            scope: .futureItems
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
}
// swiftlint:enable no_magic_numbers
