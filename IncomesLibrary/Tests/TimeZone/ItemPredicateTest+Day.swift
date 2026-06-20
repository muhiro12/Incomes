import Foundation
@testable import IncomesLibrary
import Testing

extension ItemPredicateTest {
    @Test("includes only items on the same UTC day", arguments: timeZones)
    func includesOnlySameDayItems(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let baseDate = shiftedDate("2024-04-01T00:00:00Z")
        _ = try createPredicateItem(
            date: baseDate,
            content: "TargetDay"
        )
        _ = try createPredicateItem(
            date: shiftedDate("2024-04-01T23:59:59Z"),
            content: "EndSameDay"
        )
        _ = try createPredicateItem(
            date: shiftedDate("2024-03-31T23:59:59Z"),
            content: "DayBefore"
        )
        _ = try createPredicateItem(
            date: shiftedDate("2024-04-02T00:00:00Z"),
            content: "DayAfter"
        )

        let predicate = ItemPredicate.dateIsSameDayAs(baseDate)
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("TargetDay"))
        #expect(contents.contains("EndSameDay"))
        #expect(!contents.contains("DayBefore"))
        #expect(!contents.contains("DayAfter"))
        #expect(items.count == 2)
    }

    func createPredicateItem(date: Date, content: String) throws -> Item {
        try createItem(
            context: context,
            input: .init(
                date: date,
                content: content,
                income: 1,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
    }

    @Test("includes JST 4/01 00:00 and 23:59 in same UTC day", arguments: timeZones)
    func includesFullJSTDayInUTCDay(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let jstDate1 = shiftedDate("2024-04-01T00:00:00Z")  // 2024-03-31T15:00:00Z
        let jstDate2 = shiftedDate("2024-04-01T23:59:59Z")  // 2024-04-01T15:00:00Z

        _ = try createItem(
            context: context,
            input: .init(
                date: jstDate1,
                content: "StartJSTDay",
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
                content: "EndJSTDay",
                income: 100,
                outgo: 0,
                category: "TZTest",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.dateIsSameDayAs(shiftedDate("2024-04-01T00:00:00Z"))
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("StartJSTDay"))
        #expect(contents.contains("EndJSTDay"))
        #expect(items.count == 2)
    }

    @Test("excludes items on previous or next day with same time", arguments: timeZones)
    func excludesSameTimeDifferentDay(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let baseDate = shiftedDate("2024-04-01T00:00:00Z")
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-03-31T00:00:00Z"),
                content: "PrevDay",
                income: 1,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-04-02T00:00:00Z"),
                content: "NextDay",
                income: 1,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.dateIsSameDayAs(baseDate)
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(!contents.contains("PrevDay"))
        #expect(!contents.contains("NextDay"))
        #expect(items.isEmpty)
    }

    @Test("includes item exactly at end of day UTC", arguments: timeZones)
    func includesEndOfDayUTC(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let baseDate = shiftedDate("2024-04-01T00:00:00Z")
        let endOfDay = shiftedDate("2024-04-01T23:59:59Z")
        _ = try createItem(
            context: context,
            input: .init(
                date: endOfDay,
                content: "EndOfDay",
                income: 1,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.dateIsSameDayAs(baseDate)
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["EndOfDay"])
    }

    @Test("excludes item exactly at start of next day", arguments: timeZones)
    func excludesStartOfNextDay(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let baseDate = shiftedDate("2024-04-01T00:00:00Z")
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-04-02T00:00:00Z"),
                content: "NextDayStart",
                income: 1,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.dateIsSameDayAs(baseDate)
        let items = try context.fetch(.items(predicate))

        #expect(items.isEmpty)
    }

    @Test("JST Jan 1 is treated as Dec 31 in UTC day", arguments: timeZones)
    func jstJanStartAppearsAsPreviousDay(_ timeZone: TimeZone) throws {
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

        let predicate = ItemPredicate.dateIsSameDayAs(shiftedDate("2024-01-01T00:00:00Z"))
        let items = try context.fetch(.items(predicate))

        #expect(items.map(\.content).contains("JST_Jan1"))
    }

    @Test("excludes JST 4/02 00:00 from UTC 4/01", arguments: timeZones)
    func excludesStartOfNextJSTDayFromUTCDay(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let jstDate = shiftedDate("2024-04-02T00:00:00Z") // UTC: 2024-04-01T15:00:00Z
        _ = try createItem(
            context: context,
            input: .init(
                date: jstDate,
                content: "JST_NextDay",
                income: 0,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.dateIsSameDayAs(shiftedDate("2024-04-01T00:00:00Z"))
        let items = try context.fetch(.items(predicate))

        #expect(!items.map(\.content).contains("JST_NextDay"))
    }

    @Test("excludes JST 4/01 00:00 from UTC 3/31", arguments: timeZones)
    func excludesStartOfJSTDayFromUTCDay(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let jstDate = shiftedDate("2024-04-01T00:00:00Z") // UTC: 2024-03-31T15:00:00Z
        _ = try createItem(
            context: context,
            input: .init(
                date: jstDate,
                content: "JST_StartOfDay",
                income: 0,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.dateIsSameDayAs(shiftedDate("2024-03-31T00:00:00Z"))
        let items = try context.fetch(.items(predicate))

        #expect(!items.map(\.content).contains("JST_StartOfDay"))
    }
}
