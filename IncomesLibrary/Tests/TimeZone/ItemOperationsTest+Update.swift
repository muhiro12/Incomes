import Foundation
@testable import IncomesLibrary
import Testing

extension ItemOperationsTest {
    // MARK: - Update

    // Date-move fixtures use literal values to keep balance expectations readable.
    // swiftlint:disable no_magic_numbers
    @Test("update recalculates balances when date moves later in UTC")
    func updateRecalculatesBalancesWhenDateMovesLater() throws {
        let originalTimeZone = TimeZone.ReferenceType.default
        TimeZone.ReferenceType.default = try #require(TimeZone(secondsFromGMT: 0))
        defer {
            TimeZone.ReferenceType.default = originalTimeZone
        }

        let itemToMove = try seedDateMoveLaterItems()
        try moveItemLater(itemToMove)
        try assertDateMoveLaterBalances()
    }

    @Test("update changes item values and recalculates balance", arguments: timeZones)
    func update(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createTestItem(
            input: .init(
                date: shiftedDate("2024-01-01T00:00:00Z"),
                content: "Initial",
                income: 100,
                outgo: 50,
                category: "Misc",
                priority: 0
            )
        )
        var item = try #require(fetchItems(context).first)
        try updateTestItem(
            item: item,
            input: .init(
                date: shiftedDate("2024-01-02T00:00:00Z"),
                content: "Updated",
                income: 150,
                outgo: 100,
                category: "UpdatedCat",
                priority: 0
            )
        )
        item = try #require(fetchItems(context).first)
        #expect(item.balance == 50)
        #expect(item.content == "Updated")
        #expect(item.utcDate == isoDate("2024-01-02T00:00:00Z"))
    }

    @Test("update assigns new repeatID", arguments: timeZones)
    func updateAssignsNewRepeatID(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-01-01T00:00:00Z"),
                content: "Initial",
                income: 100,
                outgo: 0,
                category: "Original",
                priority: 0
            )
        )
        let item = try #require(fetchItems(context).first)
        let oldRepeatID = item.repeatID

        try updateTestItem(
            item: item,
            input: .init(
                date: item.utcDate,
                content: "Changed",
                income: 200,
                outgo: 0,
                category: "Updated",
                priority: 0
            )
        )
        let updated = try #require(fetchItems(context).first)
        #expect(updated.repeatID != oldRepeatID)
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
    // swiftlint:enable no_magic_numbers

    @Test("update changes date and maintains correct ordering", arguments: timeZones)
    func updateChangesDateOrdering(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-01-01T00:00:00Z"),
                content: "First",
                income: 100,
                outgo: 0,
                category: "SortTest",
                priority: 0
            )
        )
        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-01-02T00:00:00Z"),
                content: "Second",
                income: 100,
                outgo: 0,
                category: "SortTest",
                priority: 0
            )
        )
        var items = try context.fetch(.items(.all)).sorted { lhs, rhs in
            lhs.utcDate < rhs.utcDate
        }
        #expect(items[0].content == "First")

        try updateTestItem(
            item: items[1],
            input: .init(
                date: isoDate("2023-12-31T00:00:00Z"),
                content: items[1].content,
                income: items[1].income,
                outgo: items[1].outgo,
                category: items[1].category?.name ?? "",
                priority: 0
            )
        )

        items = try context.fetch(.items(.all)).sorted { lhs, rhs in
            lhs.utcDate < rhs.utcDate
        }
        #expect(items[0].content == "Second")
    }

    @Test("updateForFutureItems updates only items after the target date in the repeat group", arguments: timeZones)
    func updateForFutureItems(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-01-01T00:00:00Z"),
                content: "Subscription",
                income: 0,
                outgo: 1_000,
                category: "Media",
                priority: 0
            ),
            repeatCount: 3
        )
        let items = try context.fetch(.items(.all)).sorted { lhs, rhs in
            lhs.utcDate < rhs.utcDate
        }
        let target = items[1] // middle item
        try updateTestItem(
            item: target,
            input: .init(
                date: target.utcDate,
                content: "UpdatedSub",
                income: 0,
                outgo: 1_200,
                category: "Entertainment",
                priority: 0
            ),
            scope: .futureItems
        )
        let result = try context.fetch(.items(.all)).sorted { lhs, rhs in
            lhs.utcDate < rhs.utcDate
        }
        #expect(result[0].content == "Subscription")
        #expect(result[1].content == "UpdatedSub")
        #expect(result[2].content == "UpdatedSub")
        #expect(result[1].outgo == 1_200)
        #expect(result[2].category?.name == "Entertainment")
    }

    @Test("updateForFutureItems updates only target if it's the last item", arguments: timeZones)
    func updateFutureLastOnly(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-01-01T00:00:00Z"),
                content: "Monthly",
                income: 100,
                outgo: 0,
                category: "Bills",
                priority: 0
            ),
            repeatCount: 3
        )
        let items = try context.fetch(.items(.all)).sorted { lhs, rhs in
            lhs.utcDate < rhs.utcDate
        }
        let last = items[2]

        try updateTestItem(
            item: last,
            input: .init(
                date: last.utcDate,
                content: "Changed",
                income: 200,
                outgo: 0,
                category: "BillsUpdated",
                priority: 0
            ),
            scope: .futureItems
        )
        let result = try context.fetch(.items(.all)).sorted { lhs, rhs in
            lhs.utcDate < rhs.utcDate
        }
        #expect(result[0].content == "Monthly")
        #expect(result[1].content == "Monthly")
        #expect(result[2].content == "Changed")
    }

    @Test("updateForFutureItems on non-repeating item updates only itself", arguments: timeZones)
    func updateFutureSingleRepeat(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-01-01T00:00:00Z"),
                content: "Solo",
                income: 0,
                outgo: 50,
                category: "OneTime",
                priority: 0
            )
        )
        let item = try #require(fetchItems(context).first)
        try updateTestItem(
            item: item,
            input: .init(
                date: item.utcDate,
                content: "SoloUpdated",
                income: 100,
                outgo: 50,
                category: "OneTimeUpdated",
                priority: 0
            ),
            scope: .futureItems
        )
        let updated = try #require(fetchItems(context).first)
        #expect(updated.content == "SoloUpdated")
        #expect(updated.income == 100)
    }

    @Test("updateForAllItems updates all items in the repeat group", arguments: timeZones)
    func updateForAllItems(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let item = try createTestItem(
            input: .init(
                date: isoDate("2024-02-01T00:00:00Z"),
                content: "Gym",
                income: 0,
                outgo: 8_000,
                category: "Health",
                priority: 0
            ),
            repeatCount: 3
        )
        _ = try context.fetch(.items(.all))
        let target = try #require(try context.fetchFirst(.items(.idIs(item.id))))
        try updateTestItem(
            item: target,
            input: .init(
                date: target.utcDate,
                content: "Fitness",
                income: 0,
                outgo: 7_000,
                category: "Wellness",
                priority: 0
            ),
            scope: .allItems
        )
        let updatedItems = try context.fetch(.items(.all))
        #expect(updatedItems.count == 3)
        for item in updatedItems {
            #expect(item.content == "Fitness")
            #expect(item.outgo == 7_000)
            #expect(item.category?.name == "Wellness")
        }
    }
}
