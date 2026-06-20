import Foundation
@testable import IncomesLibrary
import Testing

extension ItemPredicateTest {
    // MARK: - Outgo

    @Test("includes item with exact outgo on target date", arguments: timeZones)
    func includesItemWithExactOutgoOnDate(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let date = shiftedDate("2024-06-01T00:00:00Z")
        _ = try createItem(
            context: context,
            input: .init(
                date: date,
                content: "Match",
                income: 0,
                outgo: 5_000,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: date,
                content: "Low",
                income: 0,
                outgo: 4_999,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.outgoIsGreaterThanOrEqualTo(amount: 5_000, onOrAfter: date)
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["Match"])
    }

    @Test("excludes item before date even if outgo matches", arguments: timeZones)
    func excludesItemBeforeDateEvenIfOutgoMatches(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let cutoffDate = shiftedDate("2024-06-01T00:00:00Z")
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-05-31T23:59:59Z"),
                content: "Early",
                income: 0,
                outgo: 10_000,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: cutoffDate,
                content: "Valid",
                income: 0,
                outgo: 10_000,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.outgoIsGreaterThanOrEqualTo(amount: 5_000, onOrAfter: cutoffDate)
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["Valid"])
    }

    // MARK: - RepeatID

    @Test("includes items with matching repeat ID", arguments: timeZones)
    func includesItemsWithRepeatID(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-01-01T00:00:00Z"),
                content: "RepeatOne",
                income: 0,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        let repeatOneItem = try #require(
            try context.fetch(.items(.all)).first { item in
                item.content == "RepeatOne"
            }
        )
        let repeatID = repeatOneItem.repeatID
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-02-01T00:00:00Z"),
                content: "NonRepeat",
                income: 0,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.repeatIDIs(repeatID)
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["RepeatOne"])
    }

    @Test("includes only future repeated items", arguments: timeZones)
    func includesOnlyFutureRepeatItems(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-01-01T00:00:00Z"),
                content: "Past",
                income: 0,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 2
        )
        let repeatID = try #require(
            try context.fetch(.items(.all)).first
        ).repeatID

        let predicate = ItemPredicate.repeatIDAndDateIsAfter(
            repeatID: repeatID,
            date: shiftedDate("2024-02-01T00:00:00Z")
        )
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["Past"])
    }

    // MARK: - Content and Amount

    @Test("filters items with non-zero income", arguments: timeZones)
    func filtersNonZeroIncome(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-07-01T00:00:00Z"),
                content: "Zero",
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
                date: shiftedDate("2024-07-02T00:00:00Z"),
                content: "NonZero",
                income: 10,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.incomeIsNonZero
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["NonZero"])
    }

    @Test("filters items with outgo in range", arguments: timeZones)
    func filtersOutgoInRange(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-08-01T00:00:00Z"),
                content: "Low",
                income: 0,
                outgo: 10,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-08-02T00:00:00Z"),
                content: "Mid",
                income: 0,
                outgo: 50,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-08-03T00:00:00Z"),
                content: "High",
                income: 0,
                outgo: 100,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.outgoIsBetween(min: 20, max: 80)
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["Mid"])
    }

    @Test("filters items whose content contains a substring", arguments: timeZones)
    func filtersByContentSubstring(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-09-01T00:00:00Z"),
                content: "Grocery Store",
                income: 0,
                outgo: 20,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-09-02T00:00:00Z"),
                content: "Gas Station",
                income: 0,
                outgo: 30,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )

        let predicate = ItemPredicate.contentContains("Grocery")
        let items = try context.fetch(.items(predicate))
        let contents = items.map(\.content)

        #expect(contents == ["Grocery Store"])
    }
}
