//
//  ItemServiceTest.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/04/25.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

@Suite(.serialized)
struct ItemServiceTest {
    let context: ModelContext

    init() {
        context = testContext
    }

    @discardableResult
    func createItem(
        date: Date,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String,
        repeatCount: Int = 1
    ) throws -> Item {
        try ItemService.create(
            context: context,
            date: date,
            content: content,
            income: income,
            outgo: outgo,
            category: category,
            repeatCount: repeatCount
        )
    }

    // MARK: - Fetch

    @Test("item returns first item if available", arguments: timeZones)
    func item(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try createItem(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "First",
            income: 100,
            outgo: 50,
            category: "Test"
        )
        let item = try #require(try context.fetchFirst(.items(.all)))
        #expect(item.content == "First")
    }

    @Test("item with predicate returns only matching item", arguments: timeZones)
    func itemWithPredicate(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try createItem(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "Food",
            income: 0,
            outgo: 500,
            category: "Food"
        )
        _ = try createItem(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "Transport",
            income: 0,
            outgo: 300,
            category: "Transport"
        )
        let predicate = ItemPredicate.outgoIsGreaterThanOrEqualTo(amount: 400, onOrAfter: isoDate("2024-01-01T00:00:00Z"))
        let item = try #require(try context.fetchFirst(.items(predicate)))
        #expect(item.content == "Food")
    }

    @Test("items returns all items", arguments: timeZones)
    func items(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try createItem(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "One",
            income: 100,
            outgo: 0,
            category: "Test"
        )
        _ = try createItem(
            date: isoDate("2024-01-02T00:00:00Z"),
            content: "Two",
            income: 200,
            outgo: 0,
            category: "Test"
        )
        let items = try context.fetch(.items(.all))
        #expect(items.count == 2)
    }

    @Test("items with predicate filters matching items", arguments: timeZones)
    func itemsWithPredicate(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try createItem(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "Match",
            income: 0,
            outgo: 800,
            category: "Filtered"
        )
        _ = try createItem(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "NoMatch",
            income: 0,
            outgo: 200,
            category: "Filtered"
        )
        let predicate = ItemPredicate.outgoIsGreaterThanOrEqualTo(amount: 500, onOrAfter: isoDate("2024-01-01T00:00:00Z"))
        let filtered = try context.fetch(.items(predicate))
        #expect(filtered.count == 1)
        #expect(filtered.first?.content == "Match")
    }

    @Test("itemsCount returns correct count", arguments: timeZones)
    func itemsCount(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try createItem(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "Only",
            income: 300,
            outgo: 100,
            category: "Test"
        )
        let count = try context.fetchCount(.items(.all))
        #expect(count == 1)
    }

    @Test("itemsCount with predicate counts only matching items", arguments: timeZones)
    func itemsCountWithPredicate(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try createItem(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "X",
            income: 0,
            outgo: 900,
            category: "Filtered"
        )
        _ = try createItem(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "Y",
            income: 0,
            outgo: 100,
            category: "Filtered"
        )
        let predicate = ItemPredicate.outgoIsGreaterThanOrEqualTo(amount: 800, onOrAfter: isoDate("2024-01-01T00:00:00Z"))
        let count = try context.fetchCount(.items(predicate))
        #expect(count == 1)
    }

    // MARK: - Create

    @Test("create item with correct balance", arguments: timeZones)
    func create(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try createItem(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "Lunch",
            income: 1_000,
            outgo: 300,
            category: "Food"
        )
        let item = try #require(fetchItems(context).first)
        #expect(item.balance == 700)
    }

    @Test("create with repeatCount 3 creates 3 items with same repeatID", arguments: timeZones)
    func createWithRepeat(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try createItem(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "Rent",
            income: 0,
            outgo: 100_000,
            category: "Housing",
            repeatCount: 3
        )
        let items = fetchItems(context)
        #expect(items.count == 3)
        #expect(Set(items.map(\.repeatID)).count == 1)
    }

    @Test("create with zero repeatCount still creates one item", arguments: timeZones)
    func createWithZeroRepeat(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try createItem(
            date: isoDate("2024-03-01T00:00:00Z"),
            content: "Single",
            income: 100,
            outgo: 50,
            category: "Solo",
            repeatCount: 0
        )
        let items = fetchItems(context)
        #expect(items.count == 1)
        #expect(items.first?.content == "Single")
    }

    @Test("create with zero income and outgo results in zero balance", arguments: timeZones)
    func createWithZeroAmounts(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try createItem(
            date: isoDate("2024-03-01T00:00:00Z"),
            content: "Neutral",
            income: 0,
            outgo: 0,
            category: "Empty"
        )
        let item = try #require(fetchItems(context).first)
        #expect(item.balance == 0)
    }

    @Test("create with duplicate category names does not break", arguments: timeZones)
    func createWithDuplicateCategoryNames(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        for _ in 0..<2 {
            _ = try createItem(
                date: isoDate("2024-03-01T00:00:00Z"),
                content: "Repeated",
                income: 100,
                outgo: 50,
                category: "Shared"
            )
        }
        let items = fetchItems(context)
        #expect(items.count == 2)
        #expect(Set(items.map(\.category?.name)).count == 1)
    }

    @Test("create with end-of-month date generates all repeating items", arguments: timeZones)
    func createEndOfMonthRepeatingItems(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try createItem(
            date: isoDate("2024-01-31T00:00:00Z"),
            content: "EndMonth",
            income: 100,
            outgo: 0,
            category: "Test",
            repeatCount: 3
        )
        let items = try context.fetch(.items(.all)).sorted { first, second in
            first.utcDate < second.utcDate
        }
        #expect(items.count == 3)
        let months = items.map { item in
            item.utcDate.stringValueWithoutLocale(.yyyyMM)
        }
        #expect(months == ["2024-01", "2024-02", "2024-03"])
    }

    @Test("create stores date near midnight UTC correctly", arguments: timeZones)
    func createWithMidnightBoundary(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let boundaryDate = shiftedDate("2024-03-15T00:00:00Z")
        let item = try createItem(
            date: boundaryDate,
            content: "MidnightUTC",
            income: 100,
            outgo: 0,
            category: "Test"
        )
        let found = try #require(try context.fetchFirst(.items(.idIs(item.id))))
        #expect(found.utcDate == isoDate("2024-03-15T00:00:00Z"))
    }

    @Test("create stores JST midnight as UTC start of day", arguments: timeZones)
    func createStoresJSTMidnightAsUTCStartOfDay(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let jstDate = shiftedDate("2024-03-15T09:00:00Z")  // 00:00 UTC
        let item = try createItem(
            date: jstDate,
            content: "JSTToUTC",
            income: 100,
            outgo: 0,
            category: "Test"
        )
        let found = try #require(try context.fetchFirst(.items(.idIs(item.id))))
        #expect(found.utcDate == isoDate("2024-03-15T00:00:00Z"))
    }

    @Test("create rounds input date to start of day UTC", arguments: timeZones)
    func createRoundsDateToStartOfDay(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let inputDate = isoDate("2024-03-15T10:30:00Z")
        let expectedDate = Calendar.utc.startOfDay(for: inputDate)
        let item = try createItem(
            date: inputDate,
            content: "RoundedTime",
            income: 100,
            outgo: 0,
            category: "Test"
        )
        let found = try #require(try context.fetchFirst(.items(.idIs(item.id))))
        #expect(found.utcDate == expectedDate)
    }

    // MARK: - Update

    @Test("update changes item values and recalculates balance", arguments: timeZones)
    func update(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try createItem(
            date: shiftedDate("2024-01-01T00:00:00Z"),
            content: "Initial",
            income: 100,
            outgo: 50,
            category: "Misc"
        )
        var item = try #require(fetchItems(context).first)
        try ItemService.update(
            context: context,
            item: item,
            date: shiftedDate("2024-01-02T00:00:00Z"),
            content: "Updated",
            income: 150,
            outgo: 100,
            category: "UpdatedCat"
        )
        item = try #require(fetchItems(context).first)
        #expect(item.balance == 50)
        #expect(item.content == "Updated")
        #expect(item.utcDate == isoDate("2024-01-02T00:00:00Z"))
    }

    @Test("update assigns new repeatID", arguments: timeZones)
    func updateAssignsNewRepeatID(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try createItem(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "Initial",
            income: 100,
            outgo: 0,
            category: "Original"
        )
        let item = try #require(fetchItems(context).first)
        let oldRepeatID = item.repeatID

        try ItemService.update(
            context: context,
            item: item,
            date: item.utcDate,
            content: "Changed",
            income: 200,
            outgo: 0,
            category: "Updated"
        )
        let updated = try #require(fetchItems(context).first)
        #expect(updated.repeatID != oldRepeatID)
    }

    @Test("update changes date and maintains correct ordering", arguments: timeZones)
    func updateChangesDateOrdering(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try createItem(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "First",
            income: 100,
            outgo: 0,
            category: "SortTest"
        )
        _ = try createItem(
            date: isoDate("2024-01-02T00:00:00Z"),
            content: "Second",
            income: 100,
            outgo: 0,
            category: "SortTest"
        )
        var items = try context.fetch(.items(.all)).sorted { $0.utcDate < $1.utcDate }
        #expect(items[0].content == "First")

        try ItemService.update(
            context: context,
            item: items[1],
            date: isoDate("2023-12-31T00:00:00Z"),
            content: items[1].content,
            income: items[1].income,
            outgo: items[1].outgo,
            category: items[1].category?.name ?? ""
        )

        items = try context.fetch(.items(.all)).sorted { $0.utcDate < $1.utcDate }
        #expect(items[0].content == "Second")
    }

    @Test("updateForFutureItems updates only items after the target date in the repeat group", arguments: timeZones)
    func updateForFutureItems(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try createItem(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "Subscription",
            income: 0,
            outgo: 1_000,
            category: "Media",
            repeatCount: 3
        )
        let items = try context.fetch(.items(.all)).sorted { $0.utcDate < $1.utcDate }
        let target = items[1] // middle item
        try ItemService.updateFuture(
            context: context,
            item: target,
            date: target.utcDate,
            content: "UpdatedSub",
            income: 0,
            outgo: 1_200,
            category: "Entertainment"
        )
        let result = try context.fetch(.items(.all)).sorted { $0.utcDate < $1.utcDate }
        #expect(result[0].content == "Subscription")
        #expect(result[1].content == "UpdatedSub")
        #expect(result[2].content == "UpdatedSub")
        #expect(result[1].outgo == 1_200)
        #expect(result[2].category?.name == "Entertainment")
    }

    @Test("updateForFutureItems updates only target if it's the last item", arguments: timeZones)
    func updateFutureLastOnly(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try createItem(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "Monthly",
            income: 100,
            outgo: 0,
            category: "Bills",
            repeatCount: 3
        )
        let items = try context.fetch(.items(.all)).sorted { $0.utcDate < $1.utcDate }
        let last = items[2]

        try ItemService.updateFuture(
            context: context,
            item: last,
            date: last.utcDate,
            content: "Changed",
            income: 200,
            outgo: 0,
            category: "BillsUpdated"
        )
        let result = try context.fetch(.items(.all)).sorted { $0.utcDate < $1.utcDate }
        #expect(result[0].content == "Monthly")
        #expect(result[1].content == "Monthly")
        #expect(result[2].content == "Changed")
    }

    @Test("updateForFutureItems on non-repeating item updates only itself", arguments: timeZones)
    func updateFutureSingleRepeat(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try createItem(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "Solo",
            income: 0,
            outgo: 50,
            category: "OneTime"
        )
        let item = try #require(fetchItems(context).first)
        try ItemService.updateFuture(
            context: context,
            item: item,
            date: item.utcDate,
            content: "SoloUpdated",
            income: 100,
            outgo: 50,
            category: "OneTimeUpdated"
        )
        let updated = try #require(fetchItems(context).first)
        #expect(updated.content == "SoloUpdated")
        #expect(updated.income == 100)
    }

    @Test("updateForAllItems updates all items in the repeat group", arguments: timeZones)
    func updateForAllItems(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let item = try createItem(
            date: isoDate("2024-02-01T00:00:00Z"),
            content: "Gym",
            income: 0,
            outgo: 8_000,
            category: "Health",
            repeatCount: 3
        )
        _ = try context.fetch(.items(.all))
        let target = try #require(try context.fetchFirst(.items(.idIs(item.id))))
        try ItemService.updateAll(
            context: context,
            item: target,
            date: target.utcDate,
            content: "Fitness",
            income: 0,
            outgo: 7_000,
            category: "Wellness"
        )
        let updatedItems = try context.fetch(.items(.all))
        #expect(updatedItems.count == 3)
        for item in updatedItems {
            #expect(item.content == "Fitness")
            #expect(item.outgo == 7_000)
            #expect(item.category?.name == "Wellness")
        }
    }

    // MARK: - Delete

    @Test("delete removes the specified item", arguments: timeZones)
    func delete(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try createItem(
            date: isoDate("2024-04-01T00:00:00Z"),
            content: "ToDelete",
            income: 100,
            outgo: 0,
            category: "Temp"
        )
        let item = try #require(fetchItems(context).first)
        try ItemService.delete(
            context: context,
            item: item
        )
        let items = try context.fetch(.items(.all))
        #expect(items.isEmpty)
    }

    @Test("delete with multiple items removes only specified ones", arguments: timeZones)
    func deleteMultipleItems(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try createItem(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "KeepMe",
            income: 100,
            outgo: 0,
            category: "General"
        )
        _ = try createItem(
            date: isoDate("2024-01-02T00:00:00Z"),
            content: "RemoveMe",
            income: 100,
            outgo: 0,
            category: "General"
        )
        let allItems = try context.fetch(.items(.all))
        let toDelete = allItems.filter { $0.content == "RemoveMe" }
        try toDelete.forEach {
            try ItemService.delete(context: context, item: $0)
        }

        let remaining = try context.fetch(.items(.all))
        #expect(remaining.count == 1)
        #expect(remaining.first?.content == "KeepMe")
    }

    @Test("deleteAll clears all items", arguments: timeZones)
    func deleteAll(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try createItem(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "DeleteMe",
            income: 0,
            outgo: 100,
            category: "Tmp"
        )
        #expect(!fetchItems(context).isEmpty)
        try ItemService.deleteAll(context: context)
        #expect(fetchItems(context).isEmpty)
    }

    // MARK: - Calculate balance

    @Test("recalculate reflects updated outgo via update", arguments: timeZones)
    func recalculate(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try createItem(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "AdjustMe",
            income: 100,
            outgo: 50,
            category: "Test"
        )
        var item = try #require(fetchItems(context).first)
        try ItemService.update(
            context: context,
            item: item,
            date: item.utcDate,
            content: item.content,
            income: item.income,
            outgo: 90,
            category: item.category?.name ?? ""
        )
        item = try #require(fetchItems(context).first)
        #expect(item.balance == 10)
    }

    @Test("recalculate does not alter already correct balance", arguments: timeZones)
    func recalculateNoChange(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try createItem(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "Stable",
            income: 100,
            outgo: 60,
            category: "Check"
        )
        let item = try #require(fetchItems(context).first)
        let oldBalance = item.balance

        try ItemService.recalculate(
            context: context,
            date: isoDate("2023-12-01T00:00:00Z")
        )

        let reloaded = try #require(fetchItems(context).first)
        #expect(reloaded.balance == oldBalance)
    }

    @Test("recalculate only affects items after the specified date", arguments: timeZones)
    func recalculatePartial(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try createItem(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "Before",
            income: 100,
            outgo: 50,
            category: "Split"
        )
        _ = try createItem(
            date: isoDate("2024-02-01T00:00:00Z"),
            content: "After",
            income: 200,
            outgo: 80,
            category: "Split"
        )
        var items = try context.fetch(.items(.all)).sorted { $0.utcDate < $1.utcDate }
        try ItemService.update(
            context: context,
            item: items[1],
            date: items[1].utcDate,
            content: items[1].content,
            income: 500,
            outgo: 80,
            category: items[1].category?.name ?? ""
        )

        try ItemService.recalculate(
            context: context,
            date: isoDate("2024-01-15T00:00:00Z")
        )
        items = try context.fetch(.items(.all)).sorted { $0.utcDate < $1.utcDate }
        #expect(items[0].balance == 50)
        #expect(items[1].balance == 470)
    }

    @Test("recalculate is correct across time zone boundaries", arguments: timeZones)
    func recalculateWithTimeZoneBoundaries(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try createItem(
            date: shiftedDate("2024-02-28T15:00:00Z"),  // JST: 2024-02-29 00:00
            content: "EarlyMar",
            income: 300,
            outgo: 50,
            category: "TZTest"
        )
        _ = try createItem(
            date: shiftedDate("2024-02-28T14:00:00Z"),  // JST: 2024-02-28 23:00
            content: "LateFeb",
            income: 500,
            outgo: 100,
            category: "TZTest"
        )

        try ItemService.recalculate(
            context: context,
            date: isoDate("2024-02-01T00:00:00Z")
        )
        let items = try context.fetch(.items(.all))

        #expect(items[0].content == "LateFeb")
        #expect(items[0].balance == 650)
        #expect(items[1].content == "EarlyMar")
        #expect(items[1].balance == 250)
    }
}
