//
//  ItemServiceTest.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/04/25.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

@testable import Incomes
import SwiftData
import Testing

@Suite
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
            date: date("2024-01-01T00:00:00Z"),
            content: "First",
            income: 100,
            outgo: 50,
            category: "Test"
        )
        let item = try #require(try service.item())
        #expect(item.content == "First")
    }

    @Test("items returns all items")
    func items() throws {
        try service.create(
            date: date("2024-01-01T00:00:00Z"),
            content: "One",
            income: 100,
            outgo: 0,
            category: "Test"
        )
        try service.create(
            date: date("2024-01-02T00:00:00Z"),
            content: "Two",
            income: 200,
            outgo: 0,
            category: "Test"
        )
        let items = try service.items()
        #expect(items.count == 2)
    }

    @Test("itemsCount returns correct count")
    func itemsCount() throws {
        try service.create(
            date: date("2024-01-01T00:00:00Z"),
            content: "Only",
            income: 300,
            outgo: 100,
            category: "Test"
        )
        let count = try service.itemsCount()
        #expect(count == 1)
    }

    // MARK: - Create

    @Test("create item with correct balance")
    func create() throws {
        try service.create(
            date: date("2024-01-01T00:00:00Z"),
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
            date: date("2024-01-01T00:00:00Z"),
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

    // MARK: - Update

    @Test("update changes item values and recalculates balance")
    func update() throws {
        try service.create(
            date: date("2024-01-01T00:00:00Z"),
            content: "Initial",
            income: 100,
            outgo: 50,
            category: "Misc"
        )
        var item = try #require(fetchItems(context).first)
        try service.update(
            item: item,
            date: date("2024-01-02T00:00:00Z"),
            content: "Updated",
            income: 150,
            outgo: 100,
            category: "UpdatedCat"
        )
        item = try #require(fetchItems(context).first)
        #expect(item.balance == 50)
        #expect(item.content == "Updated")
        #expect(item.date == date("2024-01-02T00:00:00Z"))
    }

    @Test("updateForFutureItems updates only items after the target date in the repeat group")
    func updateForFutureItems() throws {
        try service.create(
            date: date("2024-01-01T00:00:00Z"),
            content: "Subscription",
            income: 0,
            outgo: 1_000,
            category: "Media",
            repeatCount: 3
        )
        let items = try service.items().sorted { $0.date < $1.date }
        let target = items[1] // middle item
        try service.updateForFutureItems(
            item: target,
            date: target.date,
            content: "UpdatedSub",
            income: 0,
            outgo: 1_200,
            category: "Entertainment"
        )
        let result = try service.items().sorted { $0.date < $1.date }
        #expect(result[0].content == "Subscription")
        #expect(result[1].content == "UpdatedSub")
        #expect(result[2].content == "UpdatedSub")
        #expect(result[1].outgo == 1_200)
        #expect(result[2].category?.name == "Entertainment")
    }

    @Test("updateForAllItems updates all items in the repeat group")
    func updateForAllItems() throws {
        try service.create(
            date: date("2024-02-01T00:00:00Z"),
            content: "Gym",
            income: 0,
            outgo: 8_000,
            category: "Health",
            repeatCount: 3
        )
        let target = try #require(try service.item())
        try service.updateForAllItems(
            item: target,
            date: target.date,
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
            date: date("2024-04-01T00:00:00Z"),
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

    @Test("deleteAll clears all items")
    func deleteAll() throws {
        try service.create(
            date: date("2024-01-01T00:00:00Z"),
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
            date: date("2024-01-01T00:00:00Z"),
            content: "AdjustMe",
            income: 100,
            outgo: 50,
            category: "Test"
        )
        var item = try #require(fetchItems(context).first)
        try service.update(
            item: item,
            date: item.date,
            content: item.content,
            income: item.income,
            outgo: 90,
            category: item.category?.name ?? ""
        )
        item = try #require(fetchItems(context).first)
        #expect(item.balance == 10)
    }
}
