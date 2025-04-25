//
//  ItemTest.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/04/25.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import Foundation
@testable import Incomes
import Testing

struct ItemTest {
    let context = testContext

    // MARK: - Create

    @Test("create assigns correct values and UTC-normalized date")
    func createAssignsCorrectValuesAndUTCNormalizedDate() throws {
        let date = isoDate("2024-03-15T10:30:00+0900")
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
            repeatID: repeatID
        )

        #expect(item.date == Calendar.utc.startOfDay(for: date))
        #expect(item.content == content)
        #expect(item.income == income)
        #expect(item.outgo == outgo)
        #expect(item.repeatID == repeatID)
        #expect(item.tags?.contains { $0.name == "202403" } == true)
    }

    @Test(
        "create normalizes boundary dates",
        .disabled("Known issue: under UTC normalization review"),
        arguments: [
            ("2023-12-31T23:59:59+0900", "2023-12-31T00:00:00Z"),
            ("2024-01-01T00:00:00+0900", "2024-01-01T00:00:00Z"),
            ("2024-01-01T08:59:59+0900", "2024-01-01T00:00:00Z"),
            ("2024-01-01T09:00:00+0900", "2024-01-01T00:00:00Z"),
            ("2024-01-01T14:59:59+0900", "2024-01-01T00:00:00Z"),
            ("2024-01-01T15:00:00+0900", "2024-01-01T00:00:00Z"),
            ("2024-03-31T23:59:59+0900", "2024-03-31T00:00:00Z"),
            ("2024-04-01T00:00:00+0900", "2024-04-01T00:00:00Z")
        ].map { (isoDate($0.0), isoDate($0.1)) }
    )
    func createNormalizesBoundaryDates(date: Date, expected: Date) throws {
        let item = try Item.create(
            context: context,
            date: date,
            content: "Check",
            income: .zero,
            outgo: .zero,
            category: "Boundary",
            repeatID: UUID()
        )
        #expect(item.date == expected)
    }

    @Test(
        "create assigns default values when optional inputs are minimal",
        .disabled("Known issue: under UTC normalization review")
    )
    func createAssignsDefaultValues() throws {
        let date = isoDate("2024-01-01T00:00:00+0900")
        let item = try Item.create(
            context: context,
            date: date,
            content: "",
            income: .zero,
            outgo: .zero,
            category: "",
            repeatID: UUID()
        )

        #expect(item.date == Calendar.utc.startOfDay(for: date))
        #expect(item.content.isEmpty)
        #expect(item.income == .zero)
        #expect(item.outgo == .zero)
        #expect(item.tags?.contains { $0.name == "202401" } == true)
    }

    @Test("create tags contain year, yearMonth, content, and category")
    func createAssignsAllExpectedTags() throws {
        let date = isoDate("2024-06-10T12:00:00+0900")
        let item = try Item.create(
            context: context,
            date: date,
            content: "Groceries",
            income: .zero,
            outgo: 5_000,
            category: "Daily",
            repeatID: UUID()
        )

        let tagNames = item.tags?.map(\.name) ?? []
        #expect(tagNames.contains("2024"))
        #expect(tagNames.contains("202406"))
        #expect(tagNames.contains("Groceries"))
        #expect(tagNames.contains("Daily"))
    }

    // MARK: - Modify

    @Test(
        "modify updates values and regenerates tags",
        .disabled("Known issue: under UTC normalization review")
    )
    func modifyUpdatesValuesAndRegeneratesTags() throws {
        let item = try Item.create(
            context: context,
            date: isoDate("2024-01-01T00:00:00+0900"),
            content: "Old",
            income: 100,
            outgo: 0,
            category: "Misc",
            repeatID: UUID()
        )

        let newDate = isoDate("2024-04-01T00:00:00+0900")
        try item.modify(
            date: newDate,
            content: "Updated",
            income: 200,
            outgo: 50,
            category: "Update",
            repeatID: UUID()
        )

        #expect(item.date == Calendar.utc.startOfDay(for: newDate))
        #expect(item.content == "Updated")
        #expect(item.income == 200)
        #expect(item.outgo == 50)
        #expect(item.tags?.contains { $0.name == "202404" } == true)
    }

    @Test(
        "modify normalizes boundary dates to UTC start of day",
        .disabled("Known issue: under UTC normalization review"),
        arguments: [
            ("2023-12-31T23:59:59+0900", "2023-12-31T00:00:00Z"),
            ("2024-01-01T00:00:00+0900", "2024-01-01T00:00:00Z"),
            ("2024-01-01T08:59:59+0900", "2024-01-01T00:00:00Z"),
            ("2024-01-01T09:00:00+0900", "2024-01-01T00:00:00Z"),
            ("2024-01-01T14:59:59+0900", "2024-01-01T00:00:00Z"),
            ("2024-01-01T15:00:00+0900", "2024-01-01T00:00:00Z"),
            ("2024-03-31T23:59:59+0900", "2024-03-31T00:00:00Z"),
            ("2024-04-01T00:00:00+0900", "2024-04-01T00:00:00Z")
        ].map { (isoDate($0.0), isoDate($0.1)) }
    )
    func modifyNormalizesBoundaryDates(date: Date, expected: Date) throws {
        let item = try Item.create(
            context: context,
            date: isoDate("2024-01-01T00:00:00+0900"),
            content: "Initial",
            income: 0,
            outgo: 0,
            category: "Init",
            repeatID: UUID()
        )

        try item.modify(
            date: date,
            content: "Updated",
            income: 100,
            outgo: 50,
            category: "Updated",
            repeatID: item.repeatID
        )

        #expect(item.date == expected)
    }

    @Test("modify preserves repeatID if reassigned to same value")
    func modifyPreservesRepeatIDIfSame() throws {
        let repeatID = UUID()
        let item = try Item.create(
            context: context,
            date: isoDate("2024-02-01T00:00:00+0900"),
            content: "Init",
            income: 0,
            outgo: 0,
            category: "Start",
            repeatID: repeatID
        )

        try item.modify(
            date: isoDate("2024-02-02T00:00:00+0900"),
            content: "Changed",
            income: 500,
            outgo: 200,
            category: "Updated",
            repeatID: repeatID
        )

        #expect(item.repeatID == repeatID)
        #expect(item.tags?.contains { $0.name == "202402" } == true)
    }

    @Test("modify updates date to correct UTC startOfDay")
    func modifyUpdatesDateToUTCDayStart() throws {
        let item = try Item.create(
            context: context,
            date: isoDate("2024-07-01T10:00:00+0900"),
            content: "Init",
            income: 0,
            outgo: 0,
            category: "Tag",
            repeatID: UUID()
        )

        let updatedDate = isoDate("2024-07-15T23:59:59+0900")
        try item.modify(
            date: updatedDate,
            content: item.content,
            income: item.income,
            outgo: item.outgo,
            category: "Tag",
            repeatID: item.repeatID
        )

        #expect(item.date == Calendar.utc.startOfDay(for: updatedDate))
    }
}
