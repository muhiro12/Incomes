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

@Suite(.serialized)
struct ItemPredicateTest {
    let context: ModelContext
    let service: ItemService

    init() {
        context = testContext
        service = .init(context: context)
    }

    // MARK: - All

    @Test("returns all items for .all predicate", arguments: timeZones)
    func returnsAllItemsWithAllPredicate(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        try service.create(date: isoDate("2024-01-01T00:00:00+0900"), content: "One", income: 100, outgo: 0, category: "A")
        try service.create(date: isoDate("2024-02-01T00:00:00+0900"), content: "Two", income: 200, outgo: 0, category: "B")

        let predicate = ItemPredicate.all
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("One"))
        #expect(contents.contains("Two"))
        #expect(items.count == 2)
    }

    // MARK: - None

    @Test("returns no items for .none predicate", arguments: timeZones)
    func returnsNoItemsWithNonePredicate(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        try service.create(date: isoDate("2024-01-01T00:00:00+0900"), content: "One", income: 100, outgo: 0, category: "A")

        let predicate = ItemPredicate.none
        let items = try service.items(.items(predicate))

        #expect(items.isEmpty)
    }

    // MARK: - Tag

    // TODO: No test methods currently provided for tagIs or tagAndYear in the original file

    // MARK: - Date

    @Test("excludes items exactly on the cutoff date for dateIsBefore", arguments: timeZones)
    func excludesItemsExactlyOnCutoffForDateIsBefore(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let cutoff = isoDate("2024-05-01T00:00:00+0900")
        try service.create(date: cutoff, content: "OnCutoff", income: 0, outgo: 0, category: "Test")

        let predicate = ItemPredicate.dateIsBefore(cutoff)
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(!contents.contains("OnCutoff"))
        #expect(items.isEmpty)
    }

    @Test("includes only items before given date", arguments: timeZones)
    func includesItemsBeforeDate(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let cutoff = isoDate("2024-05-01T00:00:00+0900")
        try service.create(date: isoDate("2024-04-30T23:59:59+0900"), content: "April", income: 1, outgo: 0, category: "Test")
        try service.create(date: cutoff, content: "May", income: 1, outgo: 0, category: "Test")

        let predicate = ItemPredicate.dateIsBefore(cutoff)
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("April"))
        #expect(!contents.contains("May"))
        #expect(items.count == 1)
    }

    @Test("includes multiple items before the cutoff date", arguments: timeZones)
    func includesMultipleItemsBeforeDate(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let cutoff = isoDate("2024-05-01T00:00:00+0900")
        try service.create(date: isoDate("2024-04-01T00:00:00+0900"), content: "EarlyApril", income: 0, outgo: 0, category: "Test")
        try service.create(date: isoDate("2024-04-15T00:00:00+0900"), content: "MidApril", income: 0, outgo: 0, category: "Test")
        try service.create(date: cutoff, content: "OnCutoff", income: 0, outgo: 0, category: "Test")

        let predicate = ItemPredicate.dateIsBefore(cutoff)
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("EarlyApril"))
        #expect(contents.contains("MidApril"))
        #expect(!contents.contains("OnCutoff"))
        #expect(items.count == 2)
    }

    @Test("includes only items after given date", arguments: timeZones)
    func includesItemsAfterDate(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let cutoff = isoDate("2024-05-01T00:00:00+0900")
        try service.create(date: isoDate("2024-05-01T00:00:01+0900"), content: "After", income: 1, outgo: 0, category: "Test")
        try service.create(date: isoDate("2024-04-30T23:59:59+0900"), content: "Before", income: 1, outgo: 0, category: "Test")

        let predicate = ItemPredicate.dateIsAfter(cutoff)
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("After"))
        #expect(!contents.contains("Before"))
        #expect(items.count == 1)
    }

    @Test("includes multiple items on and after the cutoff date", arguments: timeZones)
    func includesMultipleItemsAfterDate(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let cutoff = isoDate("2024-05-01T00:00:00+0900")
        try service.create(date: cutoff, content: "OnCutoff", income: 0, outgo: 0, category: "Test")
        try service.create(date: isoDate("2024-05-02T00:00:00+0900"), content: "MaySecond", income: 0, outgo: 0, category: "Test")
        try service.create(date: isoDate("2024-06-01T00:00:00+0900"), content: "June", income: 0, outgo: 0, category: "Test")

        let predicate = ItemPredicate.dateIsAfter(cutoff)
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("OnCutoff"))
        #expect(contents.contains("MaySecond"))
        #expect(contents.contains("June"))
        #expect(items.count == 3)
    }

    @Test("includes items exactly on the cutoff date for dateIsAfter", arguments: timeZones)
    func includesItemsExactlyOnCutoffForDateIsAfter(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let cutoff = isoDate("2024-05-01T00:00:00+0900")
        try service.create(date: cutoff, content: "OnCutoff", income: 0, outgo: 0, category: "Test")

        let predicate = ItemPredicate.dateIsAfter(cutoff)
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("OnCutoff"))
        #expect(items.count == 1)
    }

    @Test("excludes items from different year in same month", arguments: timeZones)
    func excludesDifferentYearSameMonth(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        try service.create(date: isoDate("2023-02-15T00:00:00+0900"), content: "2023Feb", income: 0, outgo: 0, category: "Test")
        try service.create(date: isoDate("2024-02-15T00:00:00+0900"), content: "2024Feb", income: 0, outgo: 0, category: "Test")

        let predicate = ItemPredicate.dateIsSameYearAs(isoDate("2024-02-01T00:00:00+0900"))
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["2024Feb"])
    }

    @Test("includes all months in the same year", arguments: timeZones)
    func includesAllMonthsInSameYear(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let baseDate = isoDate("2024-01-01T00:00:00+0900")
        try service.create(date: isoDate("2024-01-15T00:00:00+0900"), content: "January", income: 0, outgo: 0, category: "Test")
        try service.create(date: isoDate("2024-06-01T00:00:00+0900"), content: "June", income: 0, outgo: 0, category: "Test")
        try service.create(date: isoDate("2023-12-31T23:59:59+0900"), content: "LastYear", income: 0, outgo: 0, category: "Test")

        let predicate = ItemPredicate.dateIsSameYearAs(baseDate)
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("January"))
        #expect(contents.contains("June"))
        #expect(!contents.contains("LastYear"))
        #expect(items.count == 2)
    }

    @Test("JST Jan 1 is treated as January in UTC", arguments: timeZones)
    func jstJanStartAppearsAsSameYear(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let jstDate = isoDate("2024-01-01T00:00:00+0900")
        try service.create(
            date: jstDate,
            content: "JST_Jan1",
            income: 0,
            outgo: 0,
            category: "TZBoundary"
        )

        let predicate = ItemPredicate.dateIsSameYearAs(isoDate("2024-01-01T00:00:00+0900"))
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("JST_Jan1"))
    }

    @Test("includes JST 12/31 23:59 as part of same UTC year", arguments: timeZones)
    func includesEndOfJSTYearInSameUTCYear(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let jstDate = isoDate("2024-12-31T23:59:59+0900") // UTC: 2024-12-31T14:59:59Z
        try service.create(
            date: jstDate,
            content: "JST_EndOfYear",
            income: 0,
            outgo: 0,
            category: "Test"
        )

        let predicate = ItemPredicate.dateIsSameYearAs(isoDate("2024-01-01T00:00:00+0900"))
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("JST_EndOfYear"))
    }

    @Test("includes JST 1/1 00:00 in same UTC year", arguments: timeZones)
    func includesStartOfJSTYearInSameUTCYear(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let jstDate = isoDate("2024-01-01T00:00:00+0900") // UTC: 2023-12-31T15:00:00Z
        try service.create(
            date: jstDate,
            content: "JST_StartOfYear",
            income: 0,
            outgo: 0,
            category: "Test"
        )

        let predicate = ItemPredicate.dateIsSameYearAs(isoDate("2024-01-01T00:00:00+0900"))
        let items = try service.items(.items(predicate))

        #expect(items.map(\.content).contains("JST_StartOfYear"))
    }

    @Test("JST Jan 1 and Dec 31 expected in UTC year but may mismatch", arguments: timeZones)
    func jstYearBoundaryMismatchWithUTC(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let jstDate1 = isoDate("2024-01-01T00:00:00+0900")  // 2023-12-31T15:00:00Z
        let jstDate2 = isoDate("2024-12-31T23:59:59+0900")  // 2024-12-31T14:59:59Z

        try service.create(
            date: jstDate1,
            content: "StartJSTYear",
            income: 100,
            outgo: 0,
            category: "TZTest"
        )
        try service.create(
            date: jstDate2,
            content: "EndJSTYear",
            income: 100,
            outgo: 0,
            category: "TZTest"
        )

        let predicate = ItemPredicate.dateIsSameYearAs(isoDate("2024-01-01T00:00:00+0900"))
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("StartJSTYear"))
        #expect(contents.contains("EndJSTYear"))
        #expect(items.count == 2)
    }

    @Test("excludes JST 3/1 from UTC March", arguments: timeZones)
    func excludesJSTMarchStartFromUTCMarch(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let jstDate = isoDate("2024-03-01T00:00:00+0900")  // = 2024-02-29T15:00:00Z
        try service.create(
            date: jstDate,
            content: "JST_MarchStart",
            income: 0,
            outgo: 0,
            category: "Test"
        )

        let predicate = ItemPredicate.dateIsSameMonthAs(isoDate("2024-03-01T00:00:00+0900"))
        let items = try service.items(.items(predicate))
        #expect(items.map(\.content).contains("JST_MarchStart"))
    }

    @Test("includes UTC 3/1 in UTC March", arguments: timeZones)
    func includesUTCMarchStart(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let utcDate = isoDate("2024-03-01T00:00:00+0900")
        try service.create(
            date: utcDate,
            content: "UTC_MarchStart",
            income: 0,
            outgo: 0,
            category: "Test"
        )

        let predicate = ItemPredicate.dateIsSameMonthAs(isoDate("2024-03-01T00:00:00+0900"))
        let items = try service.items(.items(predicate))
        #expect(items.map(\.content).contains("UTC_MarchStart"))
        #expect(items.count == 1)
    }

    @Test("treats JST 2/1 as January in UTC", arguments: timeZones)
    func jstFebStartAppearsAsJanuary(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let jstDate = isoDate("2024-02-01T00:00:00+0900")
        try service.create(
            date: jstDate,
            content: "JSTFebStart",
            income: 100,
            outgo: 0,
            category: "TZBoundary"
        )
        let jan = ItemPredicate.dateIsSameMonthAs(isoDate("2024-01-01T00:00:00+0900"))
        let feb = ItemPredicate.dateIsSameMonthAs(isoDate("2024-02-01T00:00:00+0900"))
        let janItems = try service.items(.items(jan))
        let febItems = try service.items(.items(feb))
        #expect(!janItems.map(\.content).contains("JSTFebStart"))
        #expect(febItems.map(\.content).contains("JSTFebStart"))
    }

    @Test("treats JST 3/1 as February in UTC", arguments: timeZones)
    func jstMarStartAppearsAsFebruary(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let jstDate = isoDate("2024-03-01T00:00:00+0900")
        try service.create(
            date: jstDate,
            content: "JSTMarStart",
            income: 100,
            outgo: 0,
            category: "TZBoundary"
        )
        let feb = ItemPredicate.dateIsSameMonthAs(isoDate("2024-02-01T00:00:00+0900"))
        let mar = ItemPredicate.dateIsSameMonthAs(isoDate("2024-03-01T00:00:00+0900"))
        let febItems = try service.items(.items(feb))
        let marItems = try service.items(.items(mar))
        #expect(!febItems.map(\.content).contains("JSTMarStart"))
        #expect(marItems.map(\.content).contains("JSTMarStart"))
    }

    @Test("includes JST 2/29 23:59 as Feb in UTC", arguments: timeZones)
    func includesJSTEndOfFebInUTCFeb(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        // 2024-02-29T23:59:59+0900 = 2024-02-29T14:59:59Z
        let jstDate = isoDate("2024-02-29T23:59:59+0900")
        try service.create(
            date: jstDate,
            content: "JSTEnd",
            income: 100,
            outgo: 0,
            category: "TZTest"
        )

        let predicate = ItemPredicate.dateIsSameMonthAs(isoDate("2024-02-01T00:00:00+0900"))
        let items = try service.items(.items(predicate))

        #expect(items.count == 1)  // Should pass if UTC-based correctly
    }

    @Test("excludes JST 2/1 00:00 from UTC Feb", arguments: timeZones)
    func excludesJSTStartOfFebFromUTCFeb(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        // 2024-02-01T00:00:00+0900 = 2024-01-31T15:00:00Z
        let jstDate = isoDate("2024-02-01T00:00:00+0900")
        try service.create(
            date: jstDate,
            content: "JSTBoundary",
            income: 100,
            outgo: 0,
            category: "TZTest"
        )

        let predicate = ItemPredicate.dateIsSameMonthAs(isoDate("2024-02-01T00:00:00+0900"))
        let items = try service.items(.items(predicate))

        // This will fail if implementation interprets local time as month-boundary
        #expect(items.map(\.content).contains("JSTBoundary"))
    }

    @Test("includes all items in February UTC", arguments: timeZones)
    func includesAllItemsInFebruaryUTC(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        // Insert three items, one at start, one in middle, one at end of February (UTC)
        try service.create(
            date: isoDate("2024-02-01T00:00:00+0900"),
            content: "StartOfMonth",
            income: 100,
            outgo: 0,
            category: "TZTest"
        )
        try service.create(
            date: isoDate("2024-02-14T12:00:00+0900"),
            content: "MidMonth",
            income: 100,
            outgo: 0,
            category: "TZTest"
        )
        try service.create(
            date: isoDate("2024-02-29T23:59:59+0900"),
            content: "EndOfMonth",
            income: 100,
            outgo: 0,
            category: "TZTest"
        )

        let predicate = ItemPredicate.dateIsSameMonthAs(isoDate("2024-02-01T00:00:00+0900"))
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("StartOfMonth"))
        #expect(contents.contains("MidMonth"))
        #expect(contents.contains("EndOfMonth"))
        #expect(items.count == 3)
    }

    @Test("JST 3/1 and 3/31 are both in UTC March", arguments: timeZones)
    func jstMarchBoundaryIncludedInUTCMarch(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

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

        let predicate = ItemPredicate.dateIsSameMonthAs(isoDate("2024-03-01T00:00:00+0900"))
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["EndJST", "StartJST"])
    }

    @Test("includes only items on the same UTC day", arguments: timeZones)
    func includesOnlySameDayItems(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let baseDate = isoDate("2024-04-01T00:00:00+0900")
        try service.create(date: baseDate, content: "TargetDay", income: 1, outgo: 0, category: "Test")
        try service.create(date: isoDate("2024-04-01T23:59:59+0900"), content: "EndSameDay", income: 1, outgo: 0, category: "Test")
        try service.create(date: isoDate("2024-03-31T23:59:59+0900"), content: "DayBefore", income: 1, outgo: 0, category: "Test")
        try service.create(date: isoDate("2024-04-02T00:00:00+0900"), content: "DayAfter", income: 1, outgo: 0, category: "Test")

        let predicate = ItemPredicate.dateIsSameDayAs(baseDate)
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("TargetDay"))
        #expect(contents.contains("EndSameDay"))
        #expect(!contents.contains("DayBefore"))
        #expect(!contents.contains("DayAfter"))
        #expect(items.count == 2)
    }

    @Test("includes JST 4/01 00:00 and 23:59 in same UTC day", arguments: timeZones)
    func includesFullJSTDayInUTCDay(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let jstDate1 = isoDate("2024-04-01T00:00:00+0900")  // 2024-03-31T15:00:00Z
        let jstDate2 = isoDate("2024-04-01T23:59:59+0900")  // 2024-04-01T15:00:00Z

        try service.create(
            date: jstDate1,
            content: "StartJSTDay",
            income: 100,
            outgo: 0,
            category: "TZTest"
        )
        try service.create(
            date: jstDate2,
            content: "EndJSTDay",
            income: 100,
            outgo: 0,
            category: "TZTest"
        )

        let predicate = ItemPredicate.dateIsSameDayAs(isoDate("2024-04-01T00:00:00+0900"))
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("StartJSTDay"))
        #expect(contents.contains("EndJSTDay"))
        #expect(items.count == 2)
    }

    @Test("excludes items on previous or next day with same time", arguments: timeZones)
    func excludesSameTimeDifferentDay(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let baseDate = isoDate("2024-04-01T00:00:00+0900")
        try service.create(date: isoDate("2024-03-31T00:00:00+0900"), content: "PrevDay", income: 1, outgo: 0, category: "Test")
        try service.create(date: isoDate("2024-04-02T00:00:00+0900"), content: "NextDay", income: 1, outgo: 0, category: "Test")

        let predicate = ItemPredicate.dateIsSameDayAs(baseDate)
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(!contents.contains("PrevDay"))
        #expect(!contents.contains("NextDay"))
        #expect(items.isEmpty)
    }

    @Test("includes item exactly at end of day UTC", arguments: timeZones)
    func includesEndOfDayUTC(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let baseDate = isoDate("2024-04-01T00:00:00+0900")
        let endOfDay = isoDate("2024-04-01T23:59:59+0900")
        try service.create(date: endOfDay, content: "EndOfDay", income: 1, outgo: 0, category: "Test")

        let predicate = ItemPredicate.dateIsSameDayAs(baseDate)
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["EndOfDay"])
    }

    @Test("excludes item exactly at start of next day", arguments: timeZones)
    func excludesStartOfNextDay(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let baseDate = isoDate("2024-04-01T00:00:00+0900")
        try service.create(date: isoDate("2024-04-02T00:00:00+0900"), content: "NextDayStart", income: 1, outgo: 0, category: "Test")

        let predicate = ItemPredicate.dateIsSameDayAs(baseDate)
        let items = try service.items(.items(predicate))

        #expect(items.isEmpty)
    }

    @Test("JST Jan 1 is treated as Dec 31 in UTC day", arguments: timeZones)
    func jstJanStartAppearsAsPreviousDay(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let jstDate = isoDate("2024-01-01T00:00:00+0900")
        try service.create(
            date: jstDate,
            content: "JST_Jan1",
            income: 0,
            outgo: 0,
            category: "TZBoundary"
        )

        let predicate = ItemPredicate.dateIsSameDayAs(isoDate("2024-01-01T00:00:00+0900"))
        let items = try service.items(.items(predicate))

        #expect(items.map(\.content).contains("JST_Jan1"))
    }

    @Test("includes JST 4/02 00:00 in UTC 4/01", arguments: timeZones)
    func excludesStartOfNextJSTDayFromUTCDay(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let jstDate = isoDate("2024-04-02T00:00:00+0900") // UTC: 2024-04-01T15:00:00Z
        try service.create(
            date: jstDate,
            content: "JST_NextDay",
            income: 0,
            outgo: 0,
            category: "Test"
        )

        let predicate = ItemPredicate.dateIsSameDayAs(isoDate("2024-04-01T00:00:00+0900"))
        let items = try service.items(.items(predicate))

        #expect(!items.map(\.content).contains("JST_NextDay"))
    }

    @Test("includes JST 4/01 00:00 in UTC 3/31", arguments: timeZones)
    func includesStartOfJSTDayInPreviousUTCDay(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let jstDate = isoDate("2024-04-01T00:00:00+0900") // UTC: 2024-03-31T15:00:00Z
        try service.create(
            date: jstDate,
            content: "JST_StartOfDay",
            income: 0,
            outgo: 0,
            category: "Test"
        )

        let predicate = ItemPredicate.dateIsSameDayAs(isoDate("2024-03-31T00:00:00+0900"))
        let items = try service.items(.items(predicate))

        #expect(!items.map(\.content).contains("JST_StartOfDay"))
    }

    // MARK: - Outgo

    @Test("includes item with exact outgo on target date", arguments: timeZones)
    func includesItemWithExactOutgoOnDate(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let date = isoDate("2024-06-01T00:00:00+0900")
        try service.create(date: date, content: "Match", income: 0, outgo: 5_000, category: "Test")
        try service.create(date: date, content: "Low", income: 0, outgo: 4_999, category: "Test")

        let predicate = ItemPredicate.outgoIsGreaterThanOrEqualTo(amount: 5_000, onOrAfter: date)
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["Match"])
    }

    @Test("excludes item before date even if outgo matches", arguments: timeZones)
    func excludesItemBeforeDateEvenIfOutgoMatches(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let cutoffDate = isoDate("2024-06-01T00:00:00+0900")
        try service.create(date: isoDate("2024-05-31T23:59:59+0900"), content: "Early", income: 0, outgo: 10_000, category: "Test")
        try service.create(date: cutoffDate, content: "Valid", income: 0, outgo: 10_000, category: "Test")

        let predicate = ItemPredicate.outgoIsGreaterThanOrEqualTo(amount: 5_000, onOrAfter: cutoffDate)
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["Valid"])
    }

    // MARK: - RepeatID

    @Test("includes items with matching repeat ID", arguments: timeZones)
    func includesItemsWithRepeatID(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        try service.create(date: isoDate("2024-01-01T00:00:00+0900"), content: "RepeatOne", income: 0, outgo: 0, category: "Test")
        let repeatID = try service.item()!.repeatID

        try service.create(date: isoDate("2024-02-01T00:00:00+0900"), content: "NonRepeat", income: 0, outgo: 0, category: "Test")

        let predicate = ItemPredicate.repeatIDIs(repeatID)
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["RepeatOne"])
    }

    @Test("includes only future repeated items", arguments: timeZones)
    func includesOnlyFutureRepeatItems(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        try service.create(date: isoDate("2024-01-01T00:00:00+0900"), content: "Past", income: 0, outgo: 0, category: "Test", repeatCount: 2)
        let repeatID = try service.item()!.repeatID

        let predicate = ItemPredicate.repeatIDAndDateIsAfter(repeatID: repeatID, date: isoDate("2024-02-01T00:00:00+0900"))
        let items = try service.items(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["Past"])
    }
}
