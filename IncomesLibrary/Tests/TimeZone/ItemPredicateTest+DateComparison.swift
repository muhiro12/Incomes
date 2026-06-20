import Foundation
@testable import IncomesLibrary
import Testing

extension ItemPredicateTest {
    // MARK: - Date

    @Test("excludes items exactly on the cutoff date for dateIsBefore", arguments: timeZones)
    func excludesItemsExactlyOnCutoffForDateIsBefore(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let cutoff = shiftedDate("2024-05-01T00:00:00Z")
        _ = try createItem(
            context: context,
            input: .init(
                date: cutoff,
                content: "OnCutoff",
                income: 0,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.dateIsBefore(cutoff)
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(!contents.contains("OnCutoff"))
        #expect(items.isEmpty)
    }

    @Test("includes only items before given date", arguments: timeZones)
    func includesItemsBeforeDate(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let cutoff = shiftedDate("2024-05-01T00:00:00Z")
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-04-30T23:59:59Z"),
                content: "April",
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
                date: cutoff,
                content: "May",
                income: 1,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.dateIsBefore(cutoff)
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("April"))
        #expect(!contents.contains("May"))
        #expect(items.count == 1)
    }

    @Test("includes multiple items before the cutoff date", arguments: timeZones)
    func includesMultipleItemsBeforeDate(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let cutoff = shiftedDate("2024-05-01T00:00:00Z")
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-04-01T00:00:00Z"),
                content: "EarlyApril",
                income: 0,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-04-15T00:00:00Z"),
                content: "MidApril",
                income: 0,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: cutoff,
                content: "OnCutoff",
                income: 0,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )

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
        TimeZone.ReferenceType.default = timeZone

        let cutoff = shiftedDate("2024-05-01T00:00:00Z")
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-05-01T00:00:01Z"),
                content: "After",
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
                date: shiftedDate("2024-04-30T23:59:59Z"),
                content: "Before",
                income: 1,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.dateIsAfter(cutoff)
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("After"))
        #expect(!contents.contains("Before"))
        #expect(items.count == 1)
    }

    @Test("includes multiple items on and after the cutoff date", arguments: timeZones)
    func includesMultipleItemsAfterDate(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let cutoff = shiftedDate("2024-05-01T00:00:00Z")
        _ = try createItem(
            context: context,
            input: .init(
                date: cutoff,
                content: "OnCutoff",
                income: 0,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-05-02T00:00:00Z"),
                content: "MaySecond",
                income: 0,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-06-01T00:00:00Z"),
                content: "June",
                income: 0,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )

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
        TimeZone.ReferenceType.default = timeZone

        let cutoff = shiftedDate("2024-05-01T00:00:00Z")
        _ = try createItem(
            context: context,
            input: .init(
                date: cutoff,
                content: "OnCutoff",
                income: 0,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.dateIsAfter(cutoff)
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("OnCutoff"))
        #expect(items.count == 1)
    }

    @Test("excludes items from different year in same month", arguments: timeZones)
    func excludesDifferentYearSameMonth(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2023-02-15T00:00:00Z"),
                content: "2023Feb",
                income: 0,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-02-15T00:00:00Z"),
                content: "2024Feb",
                income: 0,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.dateIsSameYearAs(shiftedDate("2024-02-01T00:00:00Z"))
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["2024Feb"])
    }

    @Test("includes all months in the same year", arguments: timeZones)
    func includesAllMonthsInSameYear(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let baseDate = shiftedDate("2024-01-01T00:00:00Z")
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-01-15T00:00:00Z"),
                content: "January",
                income: 0,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-06-01T00:00:00Z"),
                content: "June",
                income: 0,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2023-12-31T23:59:59Z"),
                content: "LastYear",
                income: 0,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.dateIsSameYearAs(baseDate)
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents.contains("January"))
        #expect(contents.contains("June"))
        #expect(!contents.contains("LastYear"))
        #expect(items.count == 2)
    }
}
