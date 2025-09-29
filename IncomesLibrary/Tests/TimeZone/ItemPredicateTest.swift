//
//  ItemPredicateTest.swift
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
struct ItemPredicateTest {
    let context: ModelContext

    init() {
        context = testContext
    }

    // MARK: - All

    @Test("returns all items for .all predicate", arguments: timeZones)
    func returnsAllItemsWithAllPredicate(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try ItemService.create(context: context, date: shiftedDate("2024-01-01T00:00:00Z"), content: "One", income: 100, outgo: 0, category: "A", repeatCount: 1)
        _ = try ItemService.create(context: context, date: shiftedDate("2024-02-01T00:00:00Z"), content: "Two", income: 200, outgo: 0, category: "B", repeatCount: 1)

        let predicate = ItemPredicate.all
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("One"))
        #expect(contents.contains("Two"))
        #expect(items.count == 2)
    }

    // MARK: - None

    @Test("returns no items for .none predicate", arguments: timeZones)
    func returnsNoItemsWithNonePredicate(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try ItemService.create(context: context, date: shiftedDate("2024-01-01T00:00:00Z"), content: "One", income: 100, outgo: 0, category: "A", repeatCount: 1)

        let predicate = ItemPredicate.none
        let items = try context.fetch(.items(predicate))

        #expect(items.isEmpty)
    }

    // MARK: - Tag

    @Test("returns items with matching year tag", arguments: timeZones)
    func returnsItemsWithMatchingYearTag(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let date = shiftedDate("2024-01-01T00:00:00Z")
        _ = try ItemService.create(context: context, date: date, content: "Content", income: 0, outgo: 0, category: "Category", repeatCount: 1)

        let tag = try Tag.create(context: context, name: "2024", type: .year)
        let predicate = ItemPredicate.tagIs(tag)
        let items = try context.fetch(.items(predicate))

        try #require(items.count == 1)
        #expect(
            items[0].tags?.first {
                $0.type == TagType.year
            }?.name == "2024"
        )
        #expect(
            items[0].tags?.first {
                $0.type == TagType.yearMonth
            }?.name == "202401"
        )
        #expect(
            items[0].tags?.first {
                $0.type == TagType.content
            }?.name == "Content"
        )
        #expect(
            items[0].tags?.first {
                $0.type == TagType.category
            }?.name == "Category"
        )
    }

    @Test("returns items with matching yearMonth tag", arguments: timeZones)
    func returnsItemsWithMatchingYearMonthTag(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let date = shiftedDate("2024-01-01T00:00:00Z")
        _ = try ItemService.create(context: context, date: date, content: "Content", income: 0, outgo: 0, category: "Category", repeatCount: 1)

        let tag = try Tag.create(context: context, name: "202401", type: .yearMonth)
        let predicate = ItemPredicate.tagIs(tag)
        let items = try context.fetch(.items(predicate))

        try #require(items.count == 1)
        #expect(
            items[0].tags?.first {
                $0.type == TagType.year
            }?.name == "2024"
        )
        #expect(
            items[0].tags?.first {
                $0.type == TagType.yearMonth
            }?.name == "202401"
        )
        #expect(
            items[0].tags?.first {
                $0.type == TagType.content
            }?.name == "Content"
        )
        #expect(
            items[0].tags?.first {
                $0.type == TagType.category
            }?.name == "Category"
        )
    }

    @Test("returns items with matching content and year for tagAndYear", arguments: timeZones)
    func returnsItemsWithMatchingTagAndYear(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let date = shiftedDate("2024-01-01T00:00:00Z")
        _ = try ItemService.create(context: context, date: date, content: "Content", income: 0, outgo: 0, category: "Category", repeatCount: 1)

        let tag = try Tag.create(context: context, name: "Content", type: .content)
        let predicate = ItemPredicate.tagAndYear(tag: tag, yearString: "2024")
        let items = try context.fetch(.items(predicate))

        try #require(items.count == 1)
        #expect(
            items[0].tags?.first {
                $0.type == TagType.year
            }?.name == "2024"
        )
        #expect(
            items[0].tags?.first {
                $0.type == TagType.yearMonth
            }?.name == "202401"
        )
        #expect(
            items[0].tags?.first {
                $0.type == TagType.content
            }?.name == "Content"
        )
        #expect(
            items[0].tags?.first {
                $0.type == TagType.category
            }?.name == "Category"
        )
    }

    // MARK: - Date

    @Test("excludes items exactly on the cutoff date for dateIsBefore", arguments: timeZones)
    func excludesItemsExactlyOnCutoffForDateIsBefore(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let cutoff = shiftedDate("2024-05-01T00:00:00Z")
        _ = try ItemService.create(context: context, date: cutoff, content: "OnCutoff", income: 0, outgo: 0, category: "Test", repeatCount: 1)

        let predicate = ItemPredicate.dateIsBefore(cutoff)
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(!contents.contains("OnCutoff"))
        #expect(items.isEmpty)
    }

    @Test("includes only items before given date", arguments: timeZones)
    func includesItemsBeforeDate(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let cutoff = shiftedDate("2024-05-01T00:00:00Z")
        _ = try ItemService.create(context: context, date: shiftedDate("2024-04-30T23:59:59Z"), content: "April", income: 1, outgo: 0, category: "Test", repeatCount: 1)
        _ = try ItemService.create(context: context, date: cutoff, content: "May", income: 1, outgo: 0, category: "Test", repeatCount: 1)

        let predicate = ItemPredicate.dateIsBefore(cutoff)
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("April"))
        #expect(!contents.contains("May"))
        #expect(items.count == 1)
    }

    @Test("includes multiple items before the cutoff date", arguments: timeZones)
    func includesMultipleItemsBeforeDate(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let cutoff = shiftedDate("2024-05-01T00:00:00Z")
        _ = try ItemService.create(context: context, date: shiftedDate("2024-04-01T00:00:00Z"), content: "EarlyApril", income: 0, outgo: 0, category: "Test", repeatCount: 1)
        _ = try ItemService.create(context: context, date: shiftedDate("2024-04-15T00:00:00Z"), content: "MidApril", income: 0, outgo: 0, category: "Test", repeatCount: 1)
        _ = try ItemService.create(context: context, date: cutoff, content: "OnCutoff", income: 0, outgo: 0, category: "Test", repeatCount: 1)

        let predicate = ItemPredicate.dateIsBefore(cutoff)
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("EarlyApril"))
        #expect(contents.contains("MidApril"))
        #expect(!contents.contains("OnCutoff"))
        #expect(items.count == 2)
    }

    @Test("includes only items after given date", arguments: timeZones)
    func includesItemsAfterDate(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let cutoff = shiftedDate("2024-05-01T00:00:00Z")
        _ = try ItemService.create(context: context, date: shiftedDate("2024-05-01T00:00:01Z"), content: "After", income: 1, outgo: 0, category: "Test", repeatCount: 1)
        _ = try ItemService.create(context: context, date: shiftedDate("2024-04-30T23:59:59Z"), content: "Before", income: 1, outgo: 0, category: "Test", repeatCount: 1)

        let predicate = ItemPredicate.dateIsAfter(cutoff)
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("After"))
        #expect(!contents.contains("Before"))
        #expect(items.count == 1)
    }

    @Test("includes multiple items on and after the cutoff date", arguments: timeZones)
    func includesMultipleItemsAfterDate(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let cutoff = shiftedDate("2024-05-01T00:00:00Z")
        _ = try ItemService.create(context: context, date: cutoff, content: "OnCutoff", income: 0, outgo: 0, category: "Test", repeatCount: 1)
        _ = try ItemService.create(context: context, date: shiftedDate("2024-05-02T00:00:00Z"), content: "MaySecond", income: 0, outgo: 0, category: "Test", repeatCount: 1)
        _ = try ItemService.create(context: context, date: shiftedDate("2024-06-01T00:00:00Z"), content: "June", income: 0, outgo: 0, category: "Test", repeatCount: 1)

        let predicate = ItemPredicate.dateIsAfter(cutoff)
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("OnCutoff"))
        #expect(contents.contains("MaySecond"))
        #expect(contents.contains("June"))
        #expect(items.count == 3)
    }

    @Test("includes items exactly on the cutoff date for dateIsAfter", arguments: timeZones)
    func includesItemsExactlyOnCutoffForDateIsAfter(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let cutoff = shiftedDate("2024-05-01T00:00:00Z")
        _ = try ItemService.create(context: context, date: cutoff, content: "OnCutoff", income: 0, outgo: 0, category: "Test", repeatCount: 1)

        let predicate = ItemPredicate.dateIsAfter(cutoff)
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("OnCutoff"))
        #expect(items.count == 1)
    }

    @Test("excludes items from different year in same month", arguments: timeZones)
    func excludesDifferentYearSameMonth(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try ItemService.create(context: context, date: shiftedDate("2023-02-15T00:00:00Z"), content: "2023Feb", income: 0, outgo: 0, category: "Test", repeatCount: 1)
        _ = try ItemService.create(context: context, date: shiftedDate("2024-02-15T00:00:00Z"), content: "2024Feb", income: 0, outgo: 0, category: "Test", repeatCount: 1)

        let predicate = ItemPredicate.dateIsSameYearAs(shiftedDate("2024-02-01T00:00:00Z"))
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["2024Feb"])
    }

    @Test("includes all months in the same year", arguments: timeZones)
    func includesAllMonthsInSameYear(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let baseDate = shiftedDate("2024-01-01T00:00:00Z")
        _ = try ItemService.create(context: context, date: shiftedDate("2024-01-15T00:00:00Z"), content: "January", income: 0, outgo: 0, category: "Test", repeatCount: 1)
        _ = try ItemService.create(context: context, date: shiftedDate("2024-06-01T00:00:00Z"), content: "June", income: 0, outgo: 0, category: "Test", repeatCount: 1)
        _ = try ItemService.create(context: context, date: shiftedDate("2023-12-31T23:59:59Z"), content: "LastYear", income: 0, outgo: 0, category: "Test", repeatCount: 1)

        let predicate = ItemPredicate.dateIsSameYearAs(baseDate)
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("January"))
        #expect(contents.contains("June"))
        #expect(!contents.contains("LastYear"))
        #expect(items.count == 2)
    }

    @Test("JST Jan 1 is treated as January in UTC", arguments: timeZones)
    func jstJanStartAppearsAsSameYear(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let jstDate = shiftedDate("2024-01-01T00:00:00Z")
        _ = try ItemService.create(context: context,
                                   date: jstDate,
                                   content: "JST_Jan1",
                                   income: 0,
                                   outgo: 0,
                                   category: "TZBoundary",
                                   repeatCount: 1)

        let predicate = ItemPredicate.dateIsSameYearAs(shiftedDate("2024-01-01T00:00:00Z"))
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("JST_Jan1"))
    }

    @Test("includes JST 12/31 23:59 as part of same UTC year", arguments: timeZones)
    func includesEndOfJSTYearInSameUTCYear(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let jstDate = shiftedDate("2024-12-31T23:59:59Z") // UTC: 2024-12-31T14:59:59Z
        _ = try ItemService.create(context: context,
                                   date: jstDate,
                                   content: "JST_EndOfYear",
                                   income: 0,
                                   outgo: 0,
                                   category: "Test",
                                   repeatCount: 1)

        let predicate = ItemPredicate.dateIsSameYearAs(shiftedDate("2024-01-01T00:00:00Z"))
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("JST_EndOfYear"))
    }

    @Test("includes JST 1/1 00:00 in same UTC year", arguments: timeZones)
    func includesStartOfJSTYearInSameUTCYear(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let jstDate = shiftedDate("2024-01-01T00:00:00Z") // UTC: 2023-12-31T15:00:00Z
        _ = try ItemService.create(context: context,
                                   date: jstDate,
                                   content: "JST_StartOfYear",
                                   income: 0,
                                   outgo: 0,
                                   category: "Test",
                                   repeatCount: 1)

        let predicate = ItemPredicate.dateIsSameYearAs(shiftedDate("2024-01-01T00:00:00Z"))
        let items = try context.fetch(.items(predicate))

        #expect(items.map(\.content).contains("JST_StartOfYear"))
    }

    @Test("JST Jan 1 and Dec 31 expected in UTC year but may mismatch", arguments: timeZones)
    func jstYearBoundaryMismatchWithUTC(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let jstDate1 = shiftedDate("2024-01-01T00:00:00Z")  // 2023-12-31T15:00:00Z
        let jstDate2 = shiftedDate("2024-12-31T23:59:59Z")  // 2024-12-31T14:59:59Z

        _ = try ItemService.create(context: context,
                                   date: jstDate1,
                                   content: "StartJSTYear",
                                   income: 100,
                                   outgo: 0,
                                   category: "TZTest",
                                   repeatCount: 1)
        _ = try ItemService.create(context: context,
                                   date: jstDate2,
                                   content: "EndJSTYear",
                                   income: 100,
                                   outgo: 0,
                                   category: "TZTest",
                                   repeatCount: 1)

        let predicate = ItemPredicate.dateIsSameYearAs(shiftedDate("2024-01-01T00:00:00Z"))
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("StartJSTYear"))
        #expect(contents.contains("EndJSTYear"))
        #expect(items.count == 2)
    }

    @Test("includes JST 3/1 in UTC March", arguments: timeZones)
    func includesJSTMarchStartInUTCMarch(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let jstDate = shiftedDate("2024-03-01T00:00:00Z")  // = 2024-02-29T15:00:00Z
        _ = try ItemService.create(context: context,
                                   date: jstDate,
                                   content: "JST_MarchStart",
                                   income: 0,
                                   outgo: 0,
                                   category: "Test",
                                   repeatCount: 1)

        let predicate = ItemPredicate.dateIsSameMonthAs(shiftedDate("2024-03-01T00:00:00Z"))
        let items = try context.fetch(.items(predicate))
        #expect(items.map(\.content).contains("JST_MarchStart"))
    }

    @Test("includes UTC 3/1 in UTC March", arguments: timeZones)
    func includesUTCMarchStart(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let utcDate = shiftedDate("2024-03-01T00:00:00Z")
        _ = try ItemService.create(context: context,
                                   date: utcDate,
                                   content: "UTC_MarchStart",
                                   income: 0,
                                   outgo: 0,
                                   category: "Test",
                                   repeatCount: 1)

        let predicate = ItemPredicate.dateIsSameMonthAs(shiftedDate("2024-03-01T00:00:00Z"))
        let items = try context.fetch(.items(predicate))
        #expect(items.map(\.content).contains("UTC_MarchStart"))
        #expect(items.count == 1)
    }

    @Test("treats JST 2/1 as January in UTC", arguments: timeZones)
    func jstFebStartAppearsAsJanuary(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let jstDate = shiftedDate("2024-02-01T00:00:00Z")
        _ = try ItemService.create(context: context,
                                   date: jstDate,
                                   content: "JSTFebStart",
                                   income: 100,
                                   outgo: 0,
                                   category: "TZBoundary",
                                   repeatCount: 1)
        let jan = ItemPredicate.dateIsSameMonthAs(shiftedDate("2024-01-01T00:00:00Z"))
        let feb = ItemPredicate.dateIsSameMonthAs(shiftedDate("2024-02-01T00:00:00Z"))
        let janItems = try context.fetch(.items(jan))
        let febItems = try context.fetch(.items(feb))
        #expect(!janItems.map(\.content).contains("JSTFebStart"))
        #expect(febItems.map(\.content).contains("JSTFebStart"))
    }

    @Test("treats JST 3/1 as February in UTC", arguments: timeZones)
    func jstMarStartAppearsAsFebruary(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let jstDate = shiftedDate("2024-03-01T00:00:00Z")
        _ = try ItemService.create(context: context,
                                   date: jstDate,
                                   content: "JSTMarStart",
                                   income: 100,
                                   outgo: 0,
                                   category: "TZBoundary",
                                   repeatCount: 1)
        let feb = ItemPredicate.dateIsSameMonthAs(shiftedDate("2024-02-01T00:00:00Z"))
        let mar = ItemPredicate.dateIsSameMonthAs(shiftedDate("2024-03-01T00:00:00Z"))
        let febItems = try context.fetch(.items(feb))
        let marItems = try context.fetch(.items(mar))
        #expect(!febItems.map(\.content).contains("JSTMarStart"))
        #expect(marItems.map(\.content).contains("JSTMarStart"))
    }

    @Test("includes JST 2/29 23:59 as Feb in UTC", arguments: timeZones)
    func includesJSTEndOfFebInUTCFeb(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        // 2024-02-29T23:59:59+0900 = 2024-02-29T14:59:59Z
        let jstDate = shiftedDate("2024-02-29T23:59:59Z")
        _ = try ItemService.create(context: context,
                                   date: jstDate,
                                   content: "JSTEnd",
                                   income: 100,
                                   outgo: 0,
                                   category: "TZTest",
                                   repeatCount: 1)

        let predicate = ItemPredicate.dateIsSameMonthAs(shiftedDate("2024-02-01T00:00:00Z"))
        let items = try context.fetch(.items(predicate))

        #expect(items.count == 1)  // Should pass if UTC-based correctly
    }

    @Test("includes JST 2/1 00:00 in UTC Feb", arguments: timeZones)
    func includesJSTStartOfFebInUTCFeb(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        // 2024-02-01T00:00:00+0900 = 2024-01-31T15:00:00Z
        let jstDate = shiftedDate("2024-02-01T00:00:00Z")
        _ = try ItemService.create(context: context,
                                   date: jstDate,
                                   content: "JSTBoundary",
                                   income: 100,
                                   outgo: 0,
                                   category: "TZTest",
                                   repeatCount: 1)

        let predicate = ItemPredicate.dateIsSameMonthAs(shiftedDate("2024-02-01T00:00:00Z"))
        let items = try context.fetch(.items(predicate))

        // This will fail if implementation interprets local time as month-boundary
        #expect(items.map(\.content).contains("JSTBoundary"))
    }

    @Test("includes all items in February UTC", arguments: timeZones)
    func includesAllItemsInFebruaryUTC(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        // Insert three items, one at start, one in middle, one at end of February (UTC)
        _ = try ItemService.create(context: context,
                                   date: shiftedDate("2024-02-01T00:00:00Z"),
                                   content: "StartOfMonth",
                                   income: 100,
                                   outgo: 0,
                                   category: "TZTest",
                                   repeatCount: 1)
        _ = try ItemService.create(context: context,
                                   date: shiftedDate("2024-02-14T12:00:00Z"),
                                   content: "MidMonth",
                                   income: 100,
                                   outgo: 0,
                                   category: "TZTest",
                                   repeatCount: 1)
        _ = try ItemService.create(context: context,
                                   date: shiftedDate("2024-02-29T23:59:59Z"),
                                   content: "EndOfMonth",
                                   income: 100,
                                   outgo: 0,
                                   category: "TZTest",
                                   repeatCount: 1)

        let predicate = ItemPredicate.dateIsSameMonthAs(shiftedDate("2024-02-01T00:00:00Z"))
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("StartOfMonth"))
        #expect(contents.contains("MidMonth"))
        #expect(contents.contains("EndOfMonth"))
        #expect(items.count == 3)
    }

    @Test("JST 3/1 and 3/31 are both in UTC March", arguments: timeZones)
    func jstMarchBoundaryIncludedInUTCMarch(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let jstDate1 = shiftedDate("2024-03-01T00:00:00Z")  // 2024-02-29T15:00:00Z
        let jstDate2 = shiftedDate("2024-03-31T23:59:59Z")  // 2024-03-31T14:59:59Z

        _ = try ItemService.create(context: context,
                                   date: jstDate1,
                                   content: "StartJST",
                                   income: 100,
                                   outgo: 0,
                                   category: "TZTest",
                                   repeatCount: 1)
        _ = try ItemService.create(context: context,
                                   date: jstDate2,
                                   content: "EndJST",
                                   income: 100,
                                   outgo: 0,
                                   category: "TZTest",
                                   repeatCount: 1)

        let predicate = ItemPredicate.dateIsSameMonthAs(shiftedDate("2024-03-01T00:00:00Z"))
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["EndJST", "StartJST"])
    }

    @Test("includes only items on the same UTC day", arguments: timeZones)
    func includesOnlySameDayItems(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let baseDate = shiftedDate("2024-04-01T00:00:00Z")
        _ = try ItemService.create(context: context, date: baseDate, content: "TargetDay", income: 1, outgo: 0, category: "Test", repeatCount: 1)
        _ = try ItemService.create(context: context, date: shiftedDate("2024-04-01T23:59:59Z"), content: "EndSameDay", income: 1, outgo: 0, category: "Test", repeatCount: 1)
        _ = try ItemService.create(context: context, date: shiftedDate("2024-03-31T23:59:59Z"), content: "DayBefore", income: 1, outgo: 0, category: "Test", repeatCount: 1)
        _ = try ItemService.create(context: context, date: shiftedDate("2024-04-02T00:00:00Z"), content: "DayAfter", income: 1, outgo: 0, category: "Test", repeatCount: 1)

        let predicate = ItemPredicate.dateIsSameDayAs(baseDate)
        let items = try context.fetch(.items(predicate))
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

        let jstDate1 = shiftedDate("2024-04-01T00:00:00Z")  // 2024-03-31T15:00:00Z
        let jstDate2 = shiftedDate("2024-04-01T23:59:59Z")  // 2024-04-01T15:00:00Z

        _ = try ItemService.create(context: context,
                                   date: jstDate1,
                                   content: "StartJSTDay",
                                   income: 100,
                                   outgo: 0,
                                   category: "TZTest",
                                   repeatCount: 1)
        _ = try ItemService.create(context: context,
                                   date: jstDate2,
                                   content: "EndJSTDay",
                                   income: 100,
                                   outgo: 0,
                                   category: "TZTest",
                                   repeatCount: 1)

        let predicate = ItemPredicate.dateIsSameDayAs(shiftedDate("2024-04-01T00:00:00Z"))
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("StartJSTDay"))
        #expect(contents.contains("EndJSTDay"))
        #expect(items.count == 2)
    }

    @Test("excludes items on previous or next day with same time", arguments: timeZones)
    func excludesSameTimeDifferentDay(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let baseDate = shiftedDate("2024-04-01T00:00:00Z")
        _ = try ItemService.create(context: context, date: shiftedDate("2024-03-31T00:00:00Z"), content: "PrevDay", income: 1, outgo: 0, category: "Test", repeatCount: 1)
        _ = try ItemService.create(context: context, date: shiftedDate("2024-04-02T00:00:00Z"), content: "NextDay", income: 1, outgo: 0, category: "Test", repeatCount: 1)

        let predicate = ItemPredicate.dateIsSameDayAs(baseDate)
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(!contents.contains("PrevDay"))
        #expect(!contents.contains("NextDay"))
        #expect(items.isEmpty)
    }

    @Test("includes item exactly at end of day UTC", arguments: timeZones)
    func includesEndOfDayUTC(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let baseDate = shiftedDate("2024-04-01T00:00:00Z")
        let endOfDay = shiftedDate("2024-04-01T23:59:59Z")
        _ = try ItemService.create(context: context, date: endOfDay, content: "EndOfDay", income: 1, outgo: 0, category: "Test", repeatCount: 1)

        let predicate = ItemPredicate.dateIsSameDayAs(baseDate)
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["EndOfDay"])
    }

    @Test("excludes item exactly at start of next day", arguments: timeZones)
    func excludesStartOfNextDay(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let baseDate = shiftedDate("2024-04-01T00:00:00Z")
        _ = try ItemService.create(context: context, date: shiftedDate("2024-04-02T00:00:00Z"), content: "NextDayStart", income: 1, outgo: 0, category: "Test", repeatCount: 1)

        let predicate = ItemPredicate.dateIsSameDayAs(baseDate)
        let items = try context.fetch(.items(predicate))

        #expect(items.isEmpty)
    }

    @Test("JST Jan 1 is treated as Dec 31 in UTC day", arguments: timeZones)
    func jstJanStartAppearsAsPreviousDay(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let jstDate = shiftedDate("2024-01-01T00:00:00Z")
        _ = try ItemService.create(context: context,
                                   date: jstDate,
                                   content: "JST_Jan1",
                                   income: 0,
                                   outgo: 0,
                                   category: "TZBoundary",
                                   repeatCount: 1)

        let predicate = ItemPredicate.dateIsSameDayAs(shiftedDate("2024-01-01T00:00:00Z"))
        let items = try context.fetch(.items(predicate))

        #expect(items.map(\.content).contains("JST_Jan1"))
    }

    @Test("excludes JST 4/02 00:00 from UTC 4/01", arguments: timeZones)
    func excludesStartOfNextJSTDayFromUTCDay(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let jstDate = shiftedDate("2024-04-02T00:00:00Z") // UTC: 2024-04-01T15:00:00Z
        _ = try ItemService.create(context: context,
                                   date: jstDate,
                                   content: "JST_NextDay",
                                   income: 0,
                                   outgo: 0,
                                   category: "Test",
                                   repeatCount: 1)

        let predicate = ItemPredicate.dateIsSameDayAs(shiftedDate("2024-04-01T00:00:00Z"))
        let items = try context.fetch(.items(predicate))

        #expect(!items.map(\.content).contains("JST_NextDay"))
    }

    @Test("excludes JST 4/01 00:00 from UTC 3/31", arguments: timeZones)
    func excludesStartOfJSTDayFromUTCDay(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let jstDate = shiftedDate("2024-04-01T00:00:00Z") // UTC: 2024-03-31T15:00:00Z
        _ = try ItemService.create(context: context,
                                   date: jstDate,
                                   content: "JST_StartOfDay",
                                   income: 0,
                                   outgo: 0,
                                   category: "Test",
                                   repeatCount: 1)

        let predicate = ItemPredicate.dateIsSameDayAs(shiftedDate("2024-03-31T00:00:00Z"))
        let items = try context.fetch(.items(predicate))

        #expect(!items.map(\.content).contains("JST_StartOfDay"))
    }

    // MARK: - Outgo

    @Test("includes item with exact outgo on target date", arguments: timeZones)
    func includesItemWithExactOutgoOnDate(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let date = shiftedDate("2024-06-01T00:00:00Z")
        _ = try ItemService.create(context: context, date: date, content: "Match", income: 0, outgo: 5_000, category: "Test", repeatCount: 1)
        _ = try ItemService.create(context: context, date: date, content: "Low", income: 0, outgo: 4_999, category: "Test", repeatCount: 1)

        let predicate = ItemPredicate.outgoIsGreaterThanOrEqualTo(amount: 5_000, onOrAfter: date)
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["Match"])
    }

    @Test("excludes item before date even if outgo matches", arguments: timeZones)
    func excludesItemBeforeDateEvenIfOutgoMatches(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        let cutoffDate = shiftedDate("2024-06-01T00:00:00Z")
        _ = try ItemService.create(context: context, date: shiftedDate("2024-05-31T23:59:59Z"), content: "Early", income: 0, outgo: 10_000, category: "Test", repeatCount: 1)
        _ = try ItemService.create(context: context, date: cutoffDate, content: "Valid", income: 0, outgo: 10_000, category: "Test", repeatCount: 1)

        let predicate = ItemPredicate.outgoIsGreaterThanOrEqualTo(amount: 5_000, onOrAfter: cutoffDate)
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["Valid"])
    }

    // MARK: - RepeatID

    @Test("includes items with matching repeat ID", arguments: timeZones)
    func includesItemsWithRepeatID(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try ItemService.create(context: context, date: shiftedDate("2024-01-01T00:00:00Z"), content: "RepeatOne", income: 0, outgo: 0, category: "Test", repeatCount: 1)
        let repeatOneItem = try context.fetch(.items(.all)).first {
            $0.content == "RepeatOne"
        }!
        let repeatID = repeatOneItem.repeatID
        _ = try ItemService.create(context: context, date: shiftedDate("2024-02-01T00:00:00Z"), content: "NonRepeat", income: 0, outgo: 0, category: "Test", repeatCount: 1)

        let predicate = ItemPredicate.repeatIDIs(repeatID)
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["RepeatOne"])
    }

    @Test("includes only future repeated items", arguments: timeZones)
    func includesOnlyFutureRepeatItems(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try ItemService.create(context: context, date: shiftedDate("2024-01-01T00:00:00Z"), content: "Past", income: 0, outgo: 0, category: "Test", repeatCount: 2)
        let repeatID = try context.fetch(.items(.all)).first!.repeatID

        let predicate = ItemPredicate.repeatIDAndDateIsAfter(repeatID: repeatID, date: shiftedDate("2024-02-01T00:00:00Z"))
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["Past"])
    }

    // MARK: - Content and Amount

    @Test("filters items with non-zero income", arguments: timeZones)
    func filtersNonZeroIncome(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try ItemService.create(context: context, date: shiftedDate("2024-07-01T00:00:00Z"), content: "Zero", income: 0, outgo: 0, category: "Test", repeatCount: 1)
        _ = try ItemService.create(context: context, date: shiftedDate("2024-07-02T00:00:00Z"), content: "NonZero", income: 10, outgo: 0, category: "Test", repeatCount: 1)

        let predicate = ItemPredicate.incomeIsNonZero
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["NonZero"])
    }

    @Test("filters items with outgo in range", arguments: timeZones)
    func filtersOutgoInRange(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try ItemService.create(context: context, date: shiftedDate("2024-08-01T00:00:00Z"), content: "Low", income: 0, outgo: 10, category: "Test", repeatCount: 1)
        _ = try ItemService.create(context: context, date: shiftedDate("2024-08-02T00:00:00Z"), content: "Mid", income: 0, outgo: 50, category: "Test", repeatCount: 1)
        _ = try ItemService.create(context: context, date: shiftedDate("2024-08-03T00:00:00Z"), content: "High", income: 0, outgo: 100, category: "Test", repeatCount: 1)

        let predicate = ItemPredicate.outgoIsBetween(min: 20, max: 80)
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["Mid"])
    }

    @Test("filters items whose content contains a substring", arguments: timeZones)
    func filtersByContentSubstring(_ timeZone: TimeZone) throws {
        NSTimeZone.default = timeZone

        _ = try ItemService.create(context: context, date: shiftedDate("2024-09-01T00:00:00Z"), content: "Grocery Store", income: 0, outgo: 20, category: "Test", repeatCount: 1)
        _ = try ItemService.create(context: context, date: shiftedDate("2024-09-02T00:00:00Z"), content: "Gas Station", income: 0, outgo: 30, category: "Test", repeatCount: 1)

        let predicate = ItemPredicate.contentContains("Grocery")
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["Grocery Store"])
    }
}
