//
//  ItemServiceTest.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/04/25.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import Foundation
@testable import Incomes
import SwiftData
import Testing

struct ItemServiceTest {
    let context: ModelContext
    let service: ItemService

    init() {
        context = testContext
        service = .init(context: context)
    }

    // MARK: - Fetch

    @Test("item returns first item if available")
    func item() throws {
        try service.create(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "First",
            income: 100,
            outgo: 50,
            category: "Test"
        )
        let item = try #require(try service.item())
        #expect(item.content == "First")
    }

    @Test("item with predicate returns only matching item")
    func itemWithPredicate() throws {
        try service.create(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "Food",
            income: 0,
            outgo: 500,
            category: "Food"
        )
        try service.create(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "Transport",
            income: 0,
            outgo: 300,
            category: "Transport"
        )
        let predicate = ItemPredicate.outgoIsGreaterThanOrEqualTo(amount: 400, onOrAfter: isoDate("2024-01-01T00:00:00Z"))
        let item = try #require(try service.item(.items(predicate)))
        #expect(item.content == "Food")
    }

    @Test("items returns all items")
    func items() throws {
        try service.create(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "One",
            income: 100,
            outgo: 0,
            category: "Test"
        )
        try service.create(
            date: isoDate("2024-01-02T00:00:00Z"),
            content: "Two",
            income: 200,
            outgo: 0,
            category: "Test"
        )
        let items = try service.items()
        #expect(items.count == 2)
    }

    @Test("items with predicate filters matching items")
    func itemsWithPredicate() throws {
        try service.create(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "Match",
            income: 0,
            outgo: 800,
            category: "Filtered"
        )
        try service.create(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "NoMatch",
            income: 0,
            outgo: 200,
            category: "Filtered"
        )
        let predicate = ItemPredicate.outgoIsGreaterThanOrEqualTo(amount: 500, onOrAfter: isoDate("2024-01-01T00:00:00Z"))
        let filtered = try service.items(.items(predicate))
        #expect(filtered.count == 1)
        #expect(filtered.first?.content == "Match")
    }

    @Test("itemsCount returns correct count")
    func itemsCount() throws {
        try service.create(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "Only",
            income: 300,
            outgo: 100,
            category: "Test"
        )
        let count = try service.itemsCount()
        #expect(count == 1)
    }

    @Test("itemsCount with predicate counts only matching items")
    func itemsCountWithPredicate() throws {
        try service.create(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "X",
            income: 0,
            outgo: 900,
            category: "Filtered"
        )
        try service.create(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "Y",
            income: 0,
            outgo: 100,
            category: "Filtered"
        )
        let predicate = ItemPredicate.outgoIsGreaterThanOrEqualTo(amount: 800, onOrAfter: isoDate("2024-01-01T00:00:00Z"))
        let count = try service.itemsCount(.items(predicate))
        #expect(count == 1)
    }

    // MARK: - Create

    @Test("create item with correct balance")
    func create() throws {
        try service.create(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "Lunch",
            income: 1_000,
            outgo: 300,
            category: "Food"
        )
        let item = try #require(fetchItems(context).first)
        #expect(item.balance == 700)
    }

    @Test("create with repeatCount 3 creates 3 items with same repeatID")
    func createWithRepeat() throws {
        try service.create(
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

    @Test("create with zero repeatCount still creates one item")
    func createWithZeroRepeat() throws {
        try service.create(
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

    @Test("create with zero income and outgo results in zero balance")
    func createWithZeroAmounts() throws {
        try service.create(
            date: isoDate("2024-03-01T00:00:00Z"),
            content: "Neutral",
            income: 0,
            outgo: 0,
            category: "Empty"
        )
        let item = try #require(fetchItems(context).first)
        #expect(item.balance == 0)
    }

    @Test("create with duplicate category names does not break")
    func createWithDuplicateCategoryNames() throws {
        for _ in 0..<2 {
            try service.create(
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

    @Test("create stores date near midnight UTC correctly")
    func createWithMidnightBoundary() throws {
        let boundaryDate = isoDate("2024-03-15T00:00:00Z")
        try service.create(
            date: boundaryDate,
            content: "MidnightUTC",
            income: 100,
            outgo: 0,
            category: "Test"
        )
        let item = try #require(try service.item())
        #expect(item.utcDate == boundaryDate)
    }

    @Test("create stores date in JST correctly")
    func createWithJSTTimestamp() throws {
        let jstDate = isoDate("2024-03-15T09:00:00+0900")  // 00:00 UTC
        try service.create(
            date: jstDate,
            content: "JSTToUTC",
            income: 100,
            outgo: 0,
            category: "Test"
        )
        let item = try #require(try service.item())
        #expect(item.utcDate == jstDate)
    }

    @Test("create rounds input date to start of day UTC")
    func createRoundsDateToStartOfDay() throws {
        let inputDate = isoDate("2024-03-15T10:30:00Z")
        let expectedDate = Calendar.utc.startOfDay(for: inputDate)
        try service.create(
            date: inputDate,
            content: "RoundedTime",
            income: 100,
            outgo: 0,
            category: "Test"
        )
        let item = try #require(try service.item())
        #expect(item.utcDate == expectedDate)
    }

    // MARK: - Update

    @Test("update changes item values and recalculates balance")
    func update() throws {
        try service.create(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "Initial",
            income: 100,
            outgo: 50,
            category: "Misc"
        )
        var item = try #require(fetchItems(context).first)
        try service.update(
            item: item,
            date: isoDate("2024-01-02T00:00:00Z"),
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

    @Test("update assigns new repeatID")
    func updateAssignsNewRepeatID() throws {
        try service.create(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "Initial",
            income: 100,
            outgo: 0,
            category: "Original"
        )
        let item = try #require(fetchItems(context).first)
        let oldRepeatID = item.repeatID

        try service.update(
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

    @Test("update changes date and maintains correct ordering")
    func updateChangesDateOrdering() throws {
        try service.create(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "First",
            income: 100,
            outgo: 0,
            category: "SortTest"
        )
        try service.create(
            date: isoDate("2024-01-02T00:00:00Z"),
            content: "Second",
            income: 100,
            outgo: 0,
            category: "SortTest"
        )
        var items = try service.items().sorted { $0.utcDate < $1.utcDate }
        #expect(items[0].content == "First")

        try service.update(
            item: items[1],
            date: isoDate("2023-12-31T00:00:00Z"),
            content: items[1].content,
            income: items[1].income,
            outgo: items[1].outgo,
            category: items[1].category?.name ?? ""
        )

        items = try service.items().sorted { $0.utcDate < $1.utcDate }
        #expect(items[0].content == "Second")
    }

    @Test("updateForFutureItems updates only items after the target date in the repeat group")
    func updateForFutureItems() throws {
        try service.create(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "Subscription",
            income: 0,
            outgo: 1_000,
            category: "Media",
            repeatCount: 3
        )
        let items = try service.items().sorted { $0.utcDate < $1.utcDate }
        let target = items[1] // middle item
        try service.updateForFutureItems(
            item: target,
            date: target.utcDate,
            content: "UpdatedSub",
            income: 0,
            outgo: 1_200,
            category: "Entertainment"
        )
        let result = try service.items().sorted { $0.utcDate < $1.utcDate }
        #expect(result[0].content == "Subscription")
        #expect(result[1].content == "UpdatedSub")
        #expect(result[2].content == "UpdatedSub")
        #expect(result[1].outgo == 1_200)
        #expect(result[2].category?.name == "Entertainment")
    }

    @Test("updateForFutureItems updates only target if it's the last item")
    func updateFutureLastOnly() throws {
        try service.create(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "Monthly",
            income: 100,
            outgo: 0,
            category: "Bills",
            repeatCount: 3
        )
        let items = try service.items().sorted { $0.utcDate < $1.utcDate }
        let last = items[2]

        try service.updateForFutureItems(
            item: last,
            date: last.utcDate,
            content: "Changed",
            income: 200,
            outgo: 0,
            category: "BillsUpdated"
        )
        let result = try service.items().sorted { $0.utcDate < $1.utcDate }
        #expect(result[0].content == "Monthly")
        #expect(result[1].content == "Monthly")
        #expect(result[2].content == "Changed")
    }

    @Test("updateForFutureItems on non-repeating item updates only itself")
    func updateFutureSingleRepeat() throws {
        try service.create(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "Solo",
            income: 0,
            outgo: 50,
            category: "OneTime"
        )
        let item = try #require(fetchItems(context).first)
        try service.updateForFutureItems(
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

    @Test("updateForAllItems updates all items in the repeat group")
    func updateForAllItems() throws {
        try service.create(
            date: isoDate("2024-02-01T00:00:00Z"),
            content: "Gym",
            income: 0,
            outgo: 8_000,
            category: "Health",
            repeatCount: 3
        )
        let target = try #require(try service.item())
        try service.updateForAllItems(
            item: target,
            date: target.utcDate,
            content: "Fitness",
            income: 0,
            outgo: 7_000,
            category: "Wellness"
        )
        let updatedItems = try service.items()
        #expect(updatedItems.count == 3)
        for item in updatedItems {
            #expect(item.content == "Fitness")
            #expect(item.outgo == 7_000)
            #expect(item.category?.name == "Wellness")
        }
    }

    // MARK: - Delete

    @Test("delete removes the specified item")
    func delete() throws {
        try service.create(
            date: isoDate("2024-04-01T00:00:00Z"),
            content: "ToDelete",
            income: 100,
            outgo: 0,
            category: "Temp"
        )
        let item = try #require(fetchItems(context).first)
        try service.delete(items: [item])
        let items = try service.items()
        #expect(items.isEmpty)
    }

    @Test("delete with empty array does nothing")
    func deleteWithEmptyArray() throws {
        try service.delete(items: [])
        #expect(try service.items().isEmpty)
    }

    @Test("delete with multiple items removes only specified ones")
    func deleteMultipleItems() throws {
        try service.create(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "KeepMe",
            income: 100,
            outgo: 0,
            category: "General"
        )
        try service.create(
            date: isoDate("2024-01-02T00:00:00Z"),
            content: "RemoveMe",
            income: 100,
            outgo: 0,
            category: "General"
        )
        let allItems = try service.items()
        let toDelete = allItems.filter { $0.content == "RemoveMe" }
        try service.delete(items: toDelete)

        let remaining = try service.items()
        #expect(remaining.count == 1)
        #expect(remaining.first?.content == "KeepMe")
    }

    @Test("deleteAll clears all items")
    func deleteAll() throws {
        try service.create(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "DeleteMe",
            income: 0,
            outgo: 100,
            category: "Tmp"
        )
        #expect(!fetchItems(context).isEmpty)
        try service.deleteAll()
        #expect(fetchItems(context).isEmpty)
    }

    // MARK: - Calculate balance

    @Test("recalculate reflects updated outgo via update")
    func recalculate() throws {
        try service.create(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "AdjustMe",
            income: 100,
            outgo: 50,
            category: "Test"
        )
        var item = try #require(fetchItems(context).first)
        try service.update(
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

    @Test("recalculate does not alter already correct balance")
    func recalculateNoChange() throws {
        try service.create(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "Stable",
            income: 100,
            outgo: 60,
            category: "Check"
        )
        let item = try #require(fetchItems(context).first)
        let oldBalance = item.balance

        try service.recalculate(after: isoDate("2023-12-01T00:00:00Z"))

        let reloaded = try #require(fetchItems(context).first)
        #expect(reloaded.balance == oldBalance)
    }

    @Test("recalculate only affects items after the specified date")
    func recalculatePartial() throws {
        try service.create(
            date: isoDate("2024-01-01T00:00:00Z"),
            content: "Before",
            income: 100,
            outgo: 50,
            category: "Split"
        )
        try service.create(
            date: isoDate("2024-02-01T00:00:00Z"),
            content: "After",
            income: 200,
            outgo: 80,
            category: "Split"
        )
        var items = try service.items().sorted { $0.utcDate < $1.utcDate }
        try service.update(
            item: items[1],
            date: items[1].utcDate,
            content: items[1].content,
            income: 500,
            outgo: 80,
            category: items[1].category?.name ?? ""
        )

        try service.recalculate(after: isoDate("2024-01-15T00:00:00Z"))
        items = try service.items().sorted { $0.utcDate < $1.utcDate }
        #expect(items[0].balance == 50)
        #expect(items[1].balance == 470)
    }

    @Test("recalculate is correct across time zone boundaries")
    func recalculateWithTimeZoneBoundaries() throws {
        try service.create(
            date: isoDate("2024-02-28T23:00:00Z"),  // potentially Feb 29 in JST
            content: "LateFeb",
            income: 500,
            outgo: 100,
            category: "TZTest"
        )
        try service.create(
            date: isoDate("2024-02-29T01:00:00Z"),  // clearly Feb 29 UTC
            content: "EarlyMar",
            income: 300,
            outgo: 50,
            category: "TZTest"
        )

        try service.recalculate(after: isoDate("2024-02-01T00:00:00Z"))
        let items = try service.items().sorted { $0.utcDate < $1.utcDate }
        let balances = items.map(\.balance)

        #expect(balances.count == 2)
        #expect(balances[0] == 400)  // 500 - 100
        #expect(balances[1] == 650)  // 400 + (300 - 50)
    }
}
