//
//  ItemPredicateTest.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/04/25.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import Foundation
@testable import Incomes
import SwiftData
import Testing

struct ItemPredicateTest {
    let context: ModelContext
    let service: ItemService

    init() {
        context = testContext
        service = .init(context: context)
    }

    // MARK: - All

    @Test("returns all items for .all predicate")
    func returnsAllItemsWithAllPredicate() throws {
        try service.create(date: isoDate("2024-01-01T00:00:00Z"), content: "One", income: 100, outgo: 0, category: "A")
        try service.create(date: isoDate("2024-02-01T00:00:00Z"), content: "Two", income: 200, outgo: 0, category: "B")

        let predicate = ItemPredicate.all
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("One"))
        #expect(contents.contains("Two"))
        #expect(items.count == 2)
    }

    // MARK: - None

    @Test("returns no items for .none predicate")
    func returnsNoItemsWithNonePredicate() throws {
        try service.create(date: isoDate("2024-01-01T00:00:00Z"), content: "One", income: 100, outgo: 0, category: "A")

        let predicate = ItemPredicate.none
        let items = try service.items(.items(predicate))

        #expect(items.isEmpty)
    }

    // MARK: - Tag

    // TODO: No test methods currently provided for tagIs or tagAndYear in the original file

    // MARK: - Date

    @Test("excludes items exactly on the cutoff date for dateIsBefore")
    func excludesItemsExactlyOnCutoffForDateIsBefore() throws {
        let cutoff = isoDate("2024-05-01T00:00:00Z")
        try service.create(date: cutoff, content: "OnCutoff", income: 0, outgo: 0, category: "Test")

        let predicate = ItemPredicate.dateIsBefore(cutoff)
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(!contents.contains("OnCutoff"))
        #expect(items.isEmpty)
    }

    @Test("includes only items before given date")
    func includesItemsBeforeDate() throws {
        let cutoff = isoDate("2024-05-01T00:00:00Z")
        try service.create(date: isoDate("2024-04-30T23:59:59Z"), content: "April", income: 1, outgo: 0, category: "Test")
        try service.create(date: cutoff, content: "May", income: 1, outgo: 0, category: "Test")

        let predicate = ItemPredicate.dateIsBefore(cutoff)
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("April"))
        #expect(!contents.contains("May"))
        #expect(items.count == 1)
    }

    @Test("includes multiple items before the cutoff date")
    func includesMultipleItemsBeforeDate() throws {
        let cutoff = isoDate("2024-05-01T00:00:00Z")
        try service.create(date: isoDate("2024-04-01T00:00:00Z"), content: "EarlyApril", income: 0, outgo: 0, category: "Test")
        try service.create(date: isoDate("2024-04-15T00:00:00Z"), content: "MidApril", income: 0, outgo: 0, category: "Test")
        try service.create(date: cutoff, content: "OnCutoff", income: 0, outgo: 0, category: "Test")

        let predicate = ItemPredicate.dateIsBefore(cutoff)
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("EarlyApril"))
        #expect(contents.contains("MidApril"))
        #expect(!contents.contains("OnCutoff"))
        #expect(items.count == 2)
    }

    @Test("includes only items after given date")
    func includesItemsAfterDate() throws {
        let cutoff = isoDate("2024-05-01T00:00:00Z")
        try service.create(date: isoDate("2024-05-01T00:00:01Z"), content: "After", income: 1, outgo: 0, category: "Test")
        try service.create(date: isoDate("2024-04-30T23:59:59Z"), content: "Before", income: 1, outgo: 0, category: "Test")

        let predicate = ItemPredicate.dateIsAfter(cutoff)
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("After"))
        #expect(!contents.contains("Before"))
        #expect(items.count == 1)
    }

    @Test("includes multiple items on and after the cutoff date")
    func includesMultipleItemsAfterDate() throws {
        let cutoff = isoDate("2024-05-01T00:00:00Z")
        try service.create(date: cutoff, content: "OnCutoff", income: 0, outgo: 0, category: "Test")
        try service.create(date: isoDate("2024-05-02T00:00:00Z"), content: "MaySecond", income: 0, outgo: 0, category: "Test")
        try service.create(date: isoDate("2024-06-01T00:00:00Z"), content: "June", income: 0, outgo: 0, category: "Test")

        let predicate = ItemPredicate.dateIsAfter(cutoff)
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("OnCutoff"))
        #expect(contents.contains("MaySecond"))
        #expect(contents.contains("June"))
        #expect(items.count == 3)
    }

    @Test("includes items exactly on the cutoff date for dateIsAfter")
    func includesItemsExactlyOnCutoffForDateIsAfter() throws {
        let cutoff = isoDate("2024-05-01T00:00:00Z")
        try service.create(date: cutoff, content: "OnCutoff", income: 0, outgo: 0, category: "Test")

        let predicate = ItemPredicate.dateIsAfter(cutoff)
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("OnCutoff"))
        #expect(items.count == 1)
    }

    @Test("excludes items from different year in same month")
    func excludesDifferentYearSameMonth() throws {
        try service.create(date: isoDate("2023-02-15T00:00:00Z"), content: "2023Feb", income: 0, outgo: 0, category: "Test")
        try service.create(date: isoDate("2024-02-15T00:00:00Z"), content: "2024Feb", income: 0, outgo: 0, category: "Test")

        let predicate = ItemPredicate.dateIsSameYearAs(isoDate("2024-02-01T00:00:00Z"))
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["2024Feb"])
    }

    @Test("includes all months in the same year")
    func includesAllMonthsInSameYear() throws {
        let baseDate = isoDate("2024-01-01T00:00:00Z")
        try service.create(date: isoDate("2024-01-15T00:00:00Z"), content: "January", income: 0, outgo: 0, category: "Test")
        try service.create(date: isoDate("2024-06-01T00:00:00Z"), content: "June", income: 0, outgo: 0, category: "Test")
        try service.create(date: isoDate("2023-12-31T23:59:59Z"), content: "LastYear", income: 0, outgo: 0, category: "Test")

        let predicate = ItemPredicate.dateIsSameYearAs(baseDate)
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("January"))
        #expect(contents.contains("June"))
        #expect(!contents.contains("LastYear"))
        #expect(items.count == 2)
    }

    @Test("JST Jan 1 is treated as December in UTC")
    func jstJanStartAppearsAsLastYear() throws {
        let jstDate = isoDate("2024-01-01T00:00:00+0900")
        try service.create(
            date: jstDate,
            content: "JST_Jan1",
            income: 0,
            outgo: 0,
            category: "TZBoundary"
        )

        let predicate = ItemPredicate.dateIsSameYearAs(isoDate("2024-01-01T00:00:00Z"))
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(!contents.contains("JST_Jan1"))
    }

    @Test("excludes JST 3/1 from UTC March")
    func excludesJSTMarchStartFromUTCMarch() throws {
        let jstDate = isoDate("2024-03-01T00:00:00+0900")  // = 2024-02-29T15:00:00Z
        try service.create(
            date: jstDate,
            content: "JST_MarchStart",
            income: 0,
            outgo: 0,
            category: "Test"
        )

        let predicate = ItemPredicate.dateIsSameMonthAs(isoDate("2024-03-01T00:00:00Z"))
        let items = try service.items(.items(predicate))
        #expect(items.isEmpty)
    }

    @Test("includes UTC 3/1 in UTC March")
    func includesUTCMarchStart() throws {
        let utcDate = isoDate("2024-03-01T00:00:00Z")
        try service.create(
            date: utcDate,
            content: "UTC_MarchStart",
            income: 0,
            outgo: 0,
            category: "Test"
        )

        let predicate = ItemPredicate.dateIsSameMonthAs(isoDate("2024-03-01T00:00:00Z"))
        let items = try service.items(.items(predicate))
        #expect(items.map(\.content).contains("UTC_MarchStart"))
        #expect(items.count == 1)
    }

    @Test("treats JST 2/1 as January in UTC")
    func jstFebStartAppearsAsJanuary() throws {
        let jstDate = isoDate("2024-02-01T00:00:00+0900")
        try service.create(
            date: jstDate,
            content: "JSTFebStart",
            income: 100,
            outgo: 0,
            category: "TZBoundary"
        )
        let jan = ItemPredicate.dateIsSameMonthAs(isoDate("2024-01-01T00:00:00Z"))
        let feb = ItemPredicate.dateIsSameMonthAs(isoDate("2024-02-01T00:00:00Z"))
        let janItems = try service.items(.items(jan))
        let febItems = try service.items(.items(feb))
        #expect(janItems.map(\.content).contains("JSTFebStart"))
        #expect(febItems.isEmpty)
    }

    @Test("treats JST 3/1 as February in UTC")
    func jstMarStartAppearsAsFebruary() throws {
        let jstDate = isoDate("2024-03-01T00:00:00+0900")
        try service.create(
            date: jstDate,
            content: "JSTMarStart",
            income: 100,
            outgo: 0,
            category: "TZBoundary"
        )
        let feb = ItemPredicate.dateIsSameMonthAs(isoDate("2024-02-01T00:00:00Z"))
        let mar = ItemPredicate.dateIsSameMonthAs(isoDate("2024-03-01T00:00:00Z"))
        let febItems = try service.items(.items(feb))
        let marItems = try service.items(.items(mar))
        #expect(febItems.map(\.content).contains("JSTMarStart"))
        #expect(marItems.isEmpty)
    }

    @Test("includes JST 2/29 23:59 as Feb in UTC")
    func includesJSTEndOfFebInUTCFeb() throws {
        // 2024-02-29T23:59:59+0900 = 2024-02-29T14:59:59Z
        let jstDate = isoDate("2024-02-29T23:59:59+0900")
        try service.create(
            date: jstDate,
            content: "JSTEnd",
            income: 100,
            outgo: 0,
            category: "TZTest"
        )

        let predicate = ItemPredicate.dateIsSameMonthAs(isoDate("2024-02-01T00:00:00Z"))
        let items = try service.items(.items(predicate))

        #expect(items.count == 1)  // Should pass if UTC-based correctly
    }

    @Test("excludes JST 2/1 00:00 from UTC Feb")
    func excludesJSTStartOfFebFromUTCFeb() throws {
        // 2024-02-01T00:00:00+0900 = 2024-01-31T15:00:00Z
        let jstDate = isoDate("2024-02-01T00:00:00+0900")
        try service.create(
            date: jstDate,
            content: "JSTBoundary",
            income: 100,
            outgo: 0,
            category: "TZTest"
        )

        let predicate = ItemPredicate.dateIsSameMonthAs(isoDate("2024-02-01T00:00:00Z"))
        let items = try service.items(.items(predicate))

        // This will fail if implementation interprets local time as month-boundary
        #expect(items.isEmpty)
    }

    @Test("includes all items in February UTC")
    func includesAllItemsInFebruaryUTC() throws {
        // Insert three items, one at start, one in middle, one at end of February (UTC)
        try service.create(
            date: isoDate("2024-02-01T00:00:00Z"),
            content: "StartOfMonth",
            income: 100,
            outgo: 0,
            category: "TZTest"
        )
        try service.create(
            date: isoDate("2024-02-14T12:00:00Z"),
            content: "MidMonth",
            income: 100,
            outgo: 0,
            category: "TZTest"
        )
        try service.create(
            date: isoDate("2024-02-29T23:59:59Z"),
            content: "EndOfMonth",
            income: 100,
            outgo: 0,
            category: "TZTest"
        )

        let predicate = ItemPredicate.dateIsSameMonthAs(isoDate("2024-02-01T00:00:00Z"))
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("StartOfMonth"))
        #expect(contents.contains("MidMonth"))
        #expect(contents.contains("EndOfMonth"))
        #expect(items.count == 3)
    }

    @Test(
        "JST 3/1 and 3/31 expected in UTC March but may mismatch",
        .disabled("Boundary issue: JST timestamp on Mar 1 interpreted as Feb in UTC-based logic")
    )
    func jstMarchBoundaryMismatchWithUTC() throws {
        let jstDate1 = isoDate("2024-03-01T00:00:00+0900")  // 2024-02-29T15:00:00Z
        let jstDate2 = isoDate("2024-03-31T23:59:59+0900")  // 2024-03-31T14:59:59Z

        try service.create(
            date: jstDate1,
            content: "StartJST",
            income: 100,
            outgo: 0,
            category: "TZTest"
        )
        try service.create(
            date: jstDate2,
            content: "EndJST",
            income: 100,
            outgo: 0,
            category: "TZTest"
        )

        let predicate = ItemPredicate.dateIsSameMonthAs(isoDate("2024-03-01T00:00:00Z"))
        let items = try service.items(.items(predicate))

        // Confirm both items match when using strict UTC calendar
        let contents = items.map(\.content)
        #expect(contents.contains("StartJST"))
        #expect(contents.contains("EndJST"))
        #expect(items.count == 2)
    }

    @Test("includes only items on the same UTC day")
    func includesOnlySameDayItems() throws {
        let baseDate = isoDate("2024-04-01T00:00:00Z")
        try service.create(date: baseDate, content: "TargetDay", income: 1, outgo: 0, category: "Test")
        try service.create(date: isoDate("2024-04-01T23:59:59Z"), content: "EndSameDay", income: 1, outgo: 0, category: "Test")
        try service.create(date: isoDate("2024-03-31T23:59:59Z"), content: "DayBefore", income: 1, outgo: 0, category: "Test")
        try service.create(date: isoDate("2024-04-02T00:00:00Z"), content: "DayAfter", income: 1, outgo: 0, category: "Test")

        let predicate = ItemPredicate.dateIsSameDayAs(baseDate)
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("TargetDay"))
        #expect(contents.contains("EndSameDay"))
        #expect(!contents.contains("DayBefore"))
        #expect(!contents.contains("DayAfter"))
        #expect(items.count == 2)
    }

    @Test("excludes items on previous or next day with same time")
    func excludesSameTimeDifferentDay() throws {
        let baseDate = isoDate("2024-04-01T00:00:00Z")
        try service.create(date: isoDate("2024-03-31T00:00:00Z"), content: "PrevDay", income: 1, outgo: 0, category: "Test")
        try service.create(date: isoDate("2024-04-02T00:00:00Z"), content: "NextDay", income: 1, outgo: 0, category: "Test")

        let predicate = ItemPredicate.dateIsSameDayAs(baseDate)
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(!contents.contains("PrevDay"))
        #expect(!contents.contains("NextDay"))
        #expect(items.isEmpty)
    }

    @Test("includes item exactly at end of day UTC")
    func includesEndOfDayUTC() throws {
        let baseDate = isoDate("2024-04-01T00:00:00Z")
        let endOfDay = isoDate("2024-04-01T23:59:59Z")
        try service.create(date: endOfDay, content: "EndOfDay", income: 1, outgo: 0, category: "Test")

        let predicate = ItemPredicate.dateIsSameDayAs(baseDate)
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["EndOfDay"])
    }

    @Test("excludes item exactly at start of next day")
    func excludesStartOfNextDay() throws {
        let baseDate = isoDate("2024-04-01T00:00:00Z")
        try service.create(date: isoDate("2024-04-02T00:00:00Z"), content: "NextDayStart", income: 1, outgo: 0, category: "Test")

        let predicate = ItemPredicate.dateIsSameDayAs(baseDate)
        let items = try service.items(.items(predicate))

        #expect(items.isEmpty)
    }

    @Test("JST Jan 1 is treated as Dec 31 in UTC day")
    func jstJanStartAppearsAsPreviousDay() throws {
        let jstDate = isoDate("2024-01-01T00:00:00+0900")
        try service.create(
            date: jstDate,
            content: "JST_Jan1",
            income: 0,
            outgo: 0,
            category: "TZBoundary"
        )

        let predicate = ItemPredicate.dateIsSameDayAs(isoDate("2024-01-01T00:00:00Z"))
        let items = try service.items(.items(predicate))

        #expect(items.isEmpty)
    }

    // MARK: - Outgo

    @Test("includes item with exact outgo on target date")
    func includesItemWithExactOutgoOnDate() throws {
        let date = isoDate("2024-06-01T00:00:00Z")
        try service.create(date: date, content: "Match", income: 0, outgo: 5_000, category: "Test")
        try service.create(date: date, content: "Low", income: 0, outgo: 4_999, category: "Test")

        let predicate = ItemPredicate.outgoIsGreaterThanOrEqualTo(amount: 5_000, onOrAfter: date)
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["Match"])
    }

    @Test("excludes item before date even if outgo matches")
    func excludesItemBeforeDateEvenIfOutgoMatches() throws {
        let cutoffDate = isoDate("2024-06-01T00:00:00Z")
        try service.create(date: isoDate("2024-05-31T23:59:59Z"), content: "Early", income: 0, outgo: 10_000, category: "Test")
        try service.create(date: cutoffDate, content: "Valid", income: 0, outgo: 10_000, category: "Test")

        let predicate = ItemPredicate.outgoIsGreaterThanOrEqualTo(amount: 5_000, onOrAfter: cutoffDate)
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["Valid"])
    }

    // MARK: - RepeatID

    @Test("includes items with matching repeat ID")
    func includesItemsWithRepeatID() throws {
        try service.create(date: isoDate("2024-01-01T00:00:00Z"), content: "RepeatOne", income: 0, outgo: 0, category: "Test")
        let repeatID = try service.item()!.repeatID

        try service.create(date: isoDate("2024-02-01T00:00:00Z"), content: "NonRepeat", income: 0, outgo: 0, category: "Test")

        let predicate = ItemPredicate.repeatIDIs(repeatID)
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["RepeatOne"])
    }

    @Test("includes only future repeated items")
    func includesOnlyFutureRepeatItems() throws {
        try service.create(date: isoDate("2024-01-01T00:00:00Z"), content: "Past", income: 0, outgo: 0, category: "Test", repeatCount: 2)
        let repeatID = try service.item()!.repeatID

        let predicate = ItemPredicate.repeatIDAndDateIsAfter(repeatID: repeatID, date: isoDate("2024-02-01T00:00:00Z"))
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["Past"])
    }
}
