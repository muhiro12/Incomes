import Foundation
@testable import IncomesLibrary
import Testing

extension ItemOperationsTest {
    // MARK: - Fetch

    @Test("item returns first item if available", arguments: timeZones)
    func item(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-01-01T00:00:00Z"),
                content: "First",
                income: 100,
                outgo: 50,
                category: "Test",
                priority: 0
            )
        )
        let item = try #require(try context.fetchFirst(.items(.all)))
        #expect(item.content == "First")
    }

    @Test("item with predicate returns only matching item", arguments: timeZones)
    func itemWithPredicate(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-01-01T00:00:00Z"),
                content: "Food",
                income: 0,
                outgo: 500,
                category: "Food",
                priority: 0
            )
        )
        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-01-01T00:00:00Z"),
                content: "Transport",
                income: 0,
                outgo: 300,
                category: "Transport",
                priority: 0
            )
        )
        let predicate = ItemPredicate.outgoIsGreaterThanOrEqualTo(
            amount: 400,
            onOrAfter: isoDate("2024-01-01T00:00:00Z")
        )
        let item = try #require(try context.fetchFirst(.items(predicate)))
        #expect(item.content == "Food")
    }

    @Test("items returns all items", arguments: timeZones)
    func items(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-01-01T00:00:00Z"),
                content: "One",
                income: 100,
                outgo: 0,
                category: "Test",
                priority: 0
            )
        )
        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-01-02T00:00:00Z"),
                content: "Two",
                income: 200,
                outgo: 0,
                category: "Test",
                priority: 0
            )
        )
        let items = try context.fetch(.items(.all))
        #expect(items.count == 2)
    }

    @Test("items with predicate filters matching items", arguments: timeZones)
    func itemsWithPredicate(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-01-01T00:00:00Z"),
                content: "Match",
                income: 0,
                outgo: 800,
                category: "Filtered",
                priority: 0
            )
        )
        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-01-01T00:00:00Z"),
                content: "NoMatch",
                income: 0,
                outgo: 200,
                category: "Filtered",
                priority: 0
            )
        )
        let predicate = ItemPredicate.outgoIsGreaterThanOrEqualTo(
            amount: 500,
            onOrAfter: isoDate("2024-01-01T00:00:00Z")
        )
        let filtered = try context.fetch(.items(predicate))
        #expect(filtered.count == 1)
        #expect(filtered.first?.content == "Match")
    }

    @Test("itemsCount returns correct count", arguments: timeZones)
    func itemsCount(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-01-01T00:00:00Z"),
                content: "Only",
                income: 300,
                outgo: 100,
                category: "Test",
                priority: 0
            )
        )
        let count = try context.fetchCount(.items(.all))
        #expect(count == 1)
    }

    @Test("itemsCount with predicate counts only matching items", arguments: timeZones)
    func itemsCountWithPredicate(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-01-01T00:00:00Z"),
                content: "X",
                income: 0,
                outgo: 900,
                category: "Filtered",
                priority: 0
            )
        )
        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-01-01T00:00:00Z"),
                content: "Y",
                income: 0,
                outgo: 100,
                category: "Filtered",
                priority: 0
            )
        )
        let predicate = ItemPredicate.outgoIsGreaterThanOrEqualTo(
            amount: 800,
            onOrAfter: isoDate("2024-01-01T00:00:00Z")
        )
        let count = try context.fetchCount(.items(predicate))
        #expect(count == 1)
    }
}
