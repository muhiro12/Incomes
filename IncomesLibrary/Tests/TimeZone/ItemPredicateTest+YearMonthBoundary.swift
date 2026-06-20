import Foundation
@testable import IncomesLibrary
import Testing

extension ItemPredicateTest {
    @Test("JST Jan 1 is treated as January in UTC", arguments: timeZones)
    func jstJanStartAppearsAsSameYear(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let jstDate = shiftedDate("2024-01-01T00:00:00Z")
        _ = try createItem(
            context: context,
            input: .init(
                date: jstDate,
                content: "JST_Jan1",
                income: 0,
                outgo: 0,
                category: "TZBoundary",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.dateIsSameYearAs(shiftedDate("2024-01-01T00:00:00Z"))
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("JST_Jan1"))
    }

    @Test("includes JST 12/31 23:59 as part of same UTC year", arguments: timeZones)
    func includesEndOfJSTYearInSameUTCYear(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let jstDate = shiftedDate("2024-12-31T23:59:59Z") // UTC: 2024-12-31T14:59:59Z
        _ = try createItem(
            context: context,
            input: .init(
                date: jstDate,
                content: "JST_EndOfYear",
                income: 0,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.dateIsSameYearAs(shiftedDate("2024-01-01T00:00:00Z"))
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("JST_EndOfYear"))
    }

    @Test("includes JST 1/1 00:00 in same UTC year", arguments: timeZones)
    func includesStartOfJSTYearInSameUTCYear(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let jstDate = shiftedDate("2024-01-01T00:00:00Z") // UTC: 2023-12-31T15:00:00Z
        _ = try createItem(
            context: context,
            input: .init(
                date: jstDate,
                content: "JST_StartOfYear",
                income: 0,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.dateIsSameYearAs(shiftedDate("2024-01-01T00:00:00Z"))
        let items = try context.fetch(.items(predicate))

        #expect(items.map(\.content).contains("JST_StartOfYear"))
    }

    @Test("JST Jan 1 and Dec 31 expected in UTC year but may mismatch", arguments: timeZones)
    func jstYearBoundaryMismatchWithUTC(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let jstDate1 = shiftedDate("2024-01-01T00:00:00Z")  // 2023-12-31T15:00:00Z
        let jstDate2 = shiftedDate("2024-12-31T23:59:59Z")  // 2024-12-31T14:59:59Z

        _ = try createItem(
            context: context,
            input: .init(
                date: jstDate1,
                content: "StartJSTYear",
                income: 100,
                outgo: 0,
                category: "TZTest",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: jstDate2,
                content: "EndJSTYear",
                income: 100,
                outgo: 0,
                category: "TZTest",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.dateIsSameYearAs(shiftedDate("2024-01-01T00:00:00Z"))
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("StartJSTYear"))
        #expect(contents.contains("EndJSTYear"))
        #expect(items.count == 2)
    }

    @Test("includes JST 3/1 in UTC March", arguments: timeZones)
    func includesJSTMarchStartInUTCMarch(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let jstDate = shiftedDate("2024-03-01T00:00:00Z")  // = 2024-02-29T15:00:00Z
        _ = try createItem(
            context: context,
            input: .init(
                date: jstDate,
                content: "JST_MarchStart",
                income: 0,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.dateIsSameMonthAs(shiftedDate("2024-03-01T00:00:00Z"))
        let items = try context.fetch(.items(predicate))
        #expect(items.map(\.content).contains("JST_MarchStart"))
    }

    @Test("includes UTC 3/1 in UTC March", arguments: timeZones)
    func includesUTCMarchStart(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let utcDate = shiftedDate("2024-03-01T00:00:00Z")
        _ = try createItem(
            context: context,
            input: .init(
                date: utcDate,
                content: "UTC_MarchStart",
                income: 0,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.dateIsSameMonthAs(shiftedDate("2024-03-01T00:00:00Z"))
        let items = try context.fetch(.items(predicate))
        #expect(items.map(\.content).contains("UTC_MarchStart"))
        #expect(items.count == 1)
    }

    @Test("treats JST 2/1 as January in UTC", arguments: timeZones)
    func jstFebStartAppearsAsJanuary(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let jstDate = shiftedDate("2024-02-01T00:00:00Z")
        _ = try createItem(
            context: context,
            input: .init(
                date: jstDate,
                content: "JSTFebStart",
                income: 100,
                outgo: 0,
                category: "TZBoundary",
                priority: 0
            ),
            repeatCount: 1
        )
        let jan = ItemPredicate.dateIsSameMonthAs(shiftedDate("2024-01-01T00:00:00Z"))
        let feb = ItemPredicate.dateIsSameMonthAs(shiftedDate("2024-02-01T00:00:00Z"))
        let janItems = try context.fetch(.items(jan))
        let febItems = try context.fetch(.items(feb))
        #expect(!janItems.map(\.content).contains("JSTFebStart"))
        #expect(febItems.map(\.content).contains("JSTFebStart"))
    }

    @Test("treats JST 3/1 as February in UTC", arguments: timeZones)
    func jstMarStartAppearsAsFebruary(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let jstDate = shiftedDate("2024-03-01T00:00:00Z")
        _ = try createItem(
            context: context,
            input: .init(
                date: jstDate,
                content: "JSTMarStart",
                income: 100,
                outgo: 0,
                category: "TZBoundary",
                priority: 0
            ),
            repeatCount: 1
        )
        let feb = ItemPredicate.dateIsSameMonthAs(shiftedDate("2024-02-01T00:00:00Z"))
        let mar = ItemPredicate.dateIsSameMonthAs(shiftedDate("2024-03-01T00:00:00Z"))
        let febItems = try context.fetch(.items(feb))
        let marItems = try context.fetch(.items(mar))
        #expect(!febItems.map(\.content).contains("JSTMarStart"))
        #expect(marItems.map(\.content).contains("JSTMarStart"))
    }

    @Test("includes JST 2/29 23:59 as Feb in UTC", arguments: timeZones)
    func includesJSTEndOfFebInUTCFeb(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        // 2024-02-29T23:59:59+0900 = 2024-02-29T14:59:59Z
        let jstDate = shiftedDate("2024-02-29T23:59:59Z")
        _ = try createItem(
            context: context,
            input: .init(
                date: jstDate,
                content: "JSTEnd",
                income: 100,
                outgo: 0,
                category: "TZTest",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.dateIsSameMonthAs(shiftedDate("2024-02-01T00:00:00Z"))
        let items = try context.fetch(.items(predicate))

        #expect(items.count == 1)  // Should pass if UTC-based correctly
    }

    @Test("includes JST 2/1 00:00 in UTC Feb", arguments: timeZones)
    func includesJSTStartOfFebInUTCFeb(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        // 2024-02-01T00:00:00+0900 = 2024-01-31T15:00:00Z
        let jstDate = shiftedDate("2024-02-01T00:00:00Z")
        _ = try createItem(
            context: context,
            input: .init(
                date: jstDate,
                content: "JSTBoundary",
                income: 100,
                outgo: 0,
                category: "TZTest",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.dateIsSameMonthAs(shiftedDate("2024-02-01T00:00:00Z"))
        let items = try context.fetch(.items(predicate))

        // This will fail if implementation interprets local time as month-boundary
        #expect(items.map(\.content).contains("JSTBoundary"))
    }

    @Test("includes all items in February UTC", arguments: timeZones)
    func includesAllItemsInFebruaryUTC(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        // Insert three items, one at start, one in middle, one at end of February (UTC)
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-02-01T00:00:00Z"),
                content: "StartOfMonth",
                income: 100,
                outgo: 0,
                category: "TZTest",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-02-14T12:00:00Z"),
                content: "MidMonth",
                income: 100,
                outgo: 0,
                category: "TZTest",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-02-29T23:59:59Z"),
                content: "EndOfMonth",
                income: 100,
                outgo: 0,
                category: "TZTest",
                priority: 0
            ),
            repeatCount: 1
        )

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
        TimeZone.ReferenceType.default = timeZone

        let jstDate1 = shiftedDate("2024-03-01T00:00:00Z")  // 2024-02-29T15:00:00Z
        let jstDate2 = shiftedDate("2024-03-31T23:59:59Z")  // 2024-03-31T14:59:59Z

        _ = try createItem(
            context: context,
            input: .init(
                date: jstDate1,
                content: "StartJST",
                income: 100,
                outgo: 0,
                category: "TZTest",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: jstDate2,
                content: "EndJST",
                income: 100,
                outgo: 0,
                category: "TZTest",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.dateIsSameMonthAs(shiftedDate("2024-03-01T00:00:00Z"))
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["EndJST", "StartJST"])
    }
}
