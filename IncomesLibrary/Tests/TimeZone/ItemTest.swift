//
//  ItemTest.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/04/25.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import Foundation
@testable import IncomesLibrary
import Testing

@Suite(.serialized)
struct ItemTest {
    let context = testContext

    init() {
        NSTimeZone.default = .current
    }

    // MARK: - Create

    @Test("create assigns correct values and UTC-normalized date", arguments: timeZones)
    func createAssignsCorrectValuesAndUTCNormalizedDate(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let date = shiftedDate("2024-03-15T10:30:00Z")
        let content = "Lunch"
        let income = Decimal(0)
        let outgo = Decimal(1_200)
        let category = "Food"
        let repeatID = UUID()

        let item = try Item.create(
            context: context,
            date: date,
            content: content,
            income: income,
            outgo: outgo,
            category: category,
            priority: 0,
            repeatID: repeatID
        )

        #expect(item.utcDate == Calendar.utc.startOfDay(for: date))
        #expect(item.content == content)
        #expect(item.income == income)
        #expect(item.outgo == outgo)
        #expect(item.repeatID == repeatID)
        #expect(item.tags?.contains { tag in
            tag.name == "202403"
        } == true)
    }

    @Test(
        "create normalizes JST date to UTC start of day",
        arguments: [
            ("2023-12-31T23:59:59+0900", "2023-12-31T00:00:00Z"),
            ("2024-01-01T00:00:00+0900", "2024-01-01T00:00:00Z"),
            ("2024-01-01T08:59:59+0900", "2024-01-01T00:00:00Z"),
            ("2024-01-01T09:00:00+0900", "2024-01-01T00:00:00Z"),
            ("2024-01-01T14:59:59+0900", "2024-01-01T00:00:00Z"),
            ("2024-01-01T15:00:00+0900", "2024-01-01T00:00:00Z"),
            ("2024-03-31T23:59:59+0900", "2024-03-31T00:00:00Z"),
            ("2024-04-01T00:00:00+0900", "2024-04-01T00:00:00Z")
        ].map { value in
            (isoDate(value.0), isoDate(value.1))
        }
    )
    func createNormalizesJSTDateToUTCStartOfDay(date: Date, expected: Date) throws {
        NSTimeZone.default = .init(identifier: "Asia/Tokyo")!

        let item = try Item.create(
            context: context,
            date: date,
            content: "Check",
            income: .zero,
            outgo: .zero,
            category: "Boundary",
            priority: 0,
            repeatID: UUID()
        )

        #expect(item.utcDate == expected)
    }

    // TODO: Re-enable after year/month tag semantics are stabilized across time zone and formatter behavior.
    /*
     @Test("create assigns default values when optional inputs are minimal")
     func createAssignsDefaultValues() throws {
     let date = shiftedDate("2024-01-01T00:00:00Z")
     let item = try Item.create(
     context: context,
     date: date,
     content: "",
     income: .zero,
     outgo: .zero,
     category: "",
     priority: 0,
     repeatID: UUID()
     )

     #expect(item.utcDate == isoDate("2024-01-01T00:00:00Z"))
     #expect(item.content.isEmpty)
     #expect(item.income == .zero)
     #expect(item.outgo == .zero)
     #expect(item.tags?.contains { tag in
     tag.name == "202401"
     } == true)
     }
     */

    @Test("create tags contain year, yearMonth, content, and category", arguments: timeZones)
    func createAssignsAllExpectedTags(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let date = shiftedDate("2024-06-10T12:00:00Z")
        let item = try Item.create(
            context: context,
            date: date,
            content: "Groceries",
            income: .zero,
            outgo: 5_000,
            category: "Daily",
            priority: 0,
            repeatID: UUID()
        )

        let tagNames = item.tags?.map(\.name) ?? []
        #expect(tagNames.contains("2024"))
        #expect(tagNames.contains("202406"))
        #expect(tagNames.contains("Groceries"))
        #expect(tagNames.contains("Daily"))
    }

    // MARK: - Modify

    // TODO: Re-enable after year/month tag semantics are stabilized across time zone and formatter behavior.
    /*
     @Test("modify updates values and regenerates tags with UTC-normalized date")
     func modifyUpdatesValuesAndRegeneratesTags() throws {
     let item = try Item.create(
     context: context,
     date: shiftedDate("2024-01-01T00:00:00Z"),
     content: "Old",
     income: 100,
     outgo: 0,
     category: "Misc",
     priority: 0,
     repeatID: UUID()
     )

     let newDate = shiftedDate("2024-04-01T00:00:00Z")
     try item.modify(
     date: newDate,
     content: "Updated",
     income: 200,
     outgo: 50,
     category: "Update",
     priority: 0,
     repeatID: UUID()
     )

     #expect(item.utcDate == isoDate("2024-04-01T00:00:00Z"))
     #expect(item.content == "Updated")
     #expect(item.income == 200)
     #expect(item.outgo == 50)
     #expect(item.tags?.contains { tag in
     tag.name == "202404"
     } == true)
     }
     */

    @Test(
        "modify normalizes JST date to UTC start of day",
        arguments: [
            ("2023-12-31T23:59:59+0900", "2023-12-31T00:00:00Z"),
            ("2024-01-01T00:00:00+0900", "2024-01-01T00:00:00Z"),
            ("2024-01-01T08:59:59+0900", "2024-01-01T00:00:00Z"),
            ("2024-01-01T09:00:00+0900", "2024-01-01T00:00:00Z"),
            ("2024-01-01T14:59:59+0900", "2024-01-01T00:00:00Z"),
            ("2024-01-01T15:00:00+0900", "2024-01-01T00:00:00Z"),
            ("2024-03-31T23:59:59+0900", "2024-03-31T00:00:00Z"),
            ("2024-04-01T00:00:00+0900", "2024-04-01T00:00:00Z")
        ].map { value in
            (isoDate(value.0), isoDate(value.1))
        }
    )
    func modifyNormalizesJSTDateToUTCStartOfDay(date: Date, expected: Date) throws {
        NSTimeZone.default = .init(identifier: "Asia/Tokyo")!

        let item = try Item.create(
            context: context,
            date: shiftedDate("2024-01-01T00:00:00Z"),
            content: "Initial",
            income: 0,
            outgo: 0,
            category: "Init",
            priority: 0,
            repeatID: UUID()
        )

        try item.modify(
            date: date,
            content: "Updated",
            income: 100,
            outgo: 50,
            category: "Updated",
            priority: 0,
            repeatID: item.repeatID
        )

        #expect(item.utcDate == expected)
    }

    @Test("modify preserves repeatID if reassigned to same value", arguments: timeZones)
    func modifyPreservesRepeatIDIfSame(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let repeatID = UUID()
        let item = try Item.create(
            context: context,
            date: shiftedDate("2024-02-01T00:00:00Z"),
            content: "Init",
            income: 0,
            outgo: 0,
            category: "Start",
            priority: 0,
            repeatID: repeatID
        )

        try item.modify(
            date: shiftedDate("2024-02-02T00:00:00Z"),
            content: "Changed",
            income: 500,
            outgo: 200,
            category: "Updated",
            priority: 0,
            repeatID: repeatID
        )

        #expect(item.repeatID == repeatID)
        #expect(item.tags?.contains { tag in
            tag.name == "202402"
        } == true)
    }

    @Test("modify updates date to correct UTC startOfDay", arguments: timeZones)
    func modifyUpdatesDateToUTCDayStart(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let item = try Item.create(
            context: context,
            date: shiftedDate("2024-07-01T10:00:00Z"),
            content: "Init",
            income: 0,
            outgo: 0,
            category: "Tag",
            priority: 0,
            repeatID: UUID()
        )

        let updatedDate = shiftedDate("2024-07-15T23:59:59Z")
        try item.modify(
            date: updatedDate,
            content: item.content,
            income: item.income,
            outgo: item.outgo,
            category: "Tag",
            priority: 0,
            repeatID: item.repeatID
        )

        #expect(item.utcDate == isoDate("2024-07-15T00:00:00Z"))
    }

    // MARK: - Comparable

    @Test("Comparable order respects content name when priorities match", arguments: timeZones)
    func comparableNameOrderIsExpected(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let baseDate = shiftedDate("2000-01-01T12:00:00Z")
        let firstItem = try Item.create(
            context: context,
            date: baseDate,
            content: "Item A",
            income: 0,
            outgo: 10,
            category: "category",
            priority: 0,
            repeatID: UUID()
        )
        let secondItem = try Item.create(
            context: context,
            date: baseDate,
            content: "Item B",
            income: 0,
            outgo: 20,
            category: "category",
            priority: 0,
            repeatID: UUID()
        )

        let items = [firstItem, secondItem].sorted()
        #expect(items.count == 2)
        #expect(items[0].content == "Item B")
        #expect(items[1].content == "Item A")
    }

    @Test("Comparable order is as expected when priorities share the same date", arguments: timeZones)
    func comparablePriorityOrderIsExpected(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let baseDate = shiftedDate("2000-01-01T12:00:00Z")
        let lowPriorityItem = try Item.create(
            context: context,
            date: baseDate,
            content: "Item A",
            income: 0,
            outgo: 50,
            category: "category",
            priority: 0,
            repeatID: UUID()
        )
        let highPriorityItem = try Item.create(
            context: context,
            date: baseDate,
            content: "Item B",
            income: 100,
            outgo: 0,
            category: "category",
            priority: 1,
            repeatID: UUID()
        )

        let items = [lowPriorityItem, highPriorityItem].sorted()
        #expect(items.count == 2)
        #expect(items[0].content == "Item A")
        #expect(items[1].content == "Item B")
    }

    @Test("Comparable order is consistent between priority 0/1 and 1/2", arguments: timeZones)
    func comparablePriorityOrderIsConsistent(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let baseDate = shiftedDate("2000-01-01T12:00:00Z")
        let firstItem = try Item.create(
            context: context,
            date: baseDate,
            content: "Item A",
            income: 0,
            outgo: 10,
            category: "category",
            priority: 1,
            repeatID: UUID()
        )
        let secondItem = try Item.create(
            context: context,
            date: baseDate,
            content: "Item B",
            income: 0,
            outgo: 20,
            category: "category",
            priority: 2,
            repeatID: UUID()
        )

        let items = [firstItem, secondItem].sorted()
        #expect(items.count == 2)
        #expect(items[0].content == "Item A")
        #expect(items[1].content == "Item B")
    }
}
