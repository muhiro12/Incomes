import Foundation
@testable import IncomesLibrary
import Testing

extension ItemOperationsTest {
    // MARK: - Calculate balance

    @Test("recalculate reflects updated outgo via update", arguments: timeZones)
    func recalculate(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-01-01T00:00:00Z"),
                content: "AdjustMe",
                income: 100,
                outgo: 50,
                category: "Test",
                priority: 0
            )
        )
        var item = try #require(fetchItems(context).first)
        try updateTestItem(
            item: item,
            input: .init(
                date: item.utcDate,
                content: item.content,
                income: item.income,
                outgo: 90,
                category: item.category?.name ?? "",
                priority: 0
            )
        )
        item = try #require(fetchItems(context).first)
        #expect(item.balance == 10)
    }

    @Test("recalculate does not alter already correct balance", arguments: timeZones)
    func recalculateNoChange(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-01-01T00:00:00Z"),
                content: "Stable",
                income: 100,
                outgo: 60,
                category: "Check",
                priority: 0
            )
        )
        let item = try #require(fetchItems(context).first)
        let oldBalance = item.balance

        try ItemBalanceOperations.recalculate(
            context: context,
            date: isoDate("2023-12-01T00:00:00Z")
        )

        let reloaded = try #require(fetchItems(context).first)
        #expect(reloaded.balance == oldBalance)
    }

    @Test("recalculate only affects items after the specified date", arguments: timeZones)
    func recalculatePartial(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-01-01T00:00:00Z"),
                content: "Before",
                income: 100,
                outgo: 50,
                category: "Split",
                priority: 0
            )
        )
        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-02-01T00:00:00Z"),
                content: "After",
                income: 200,
                outgo: 80,
                category: "Split",
                priority: 0
            )
        )
        var items = try context.fetch(.items(.all)).sorted { lhs, rhs in
            lhs.utcDate < rhs.utcDate
        }
        try updateTestItem(
            item: items[1],
            input: .init(
                date: items[1].utcDate,
                content: items[1].content,
                income: 500,
                outgo: 80,
                category: items[1].category?.name ?? "",
                priority: 0
            )
        )

        try ItemBalanceOperations.recalculate(
            context: context,
            date: isoDate("2024-01-15T00:00:00Z")
        )
        items = try context.fetch(.items(.all)).sorted { lhs, rhs in
            lhs.utcDate < rhs.utcDate
        }
        #expect(items[0].balance == 50)
        #expect(items[1].balance == 470)
    }

    @Test("recalculate is correct across time zone boundaries", arguments: timeZones)
    func recalculateWithTimeZoneBoundaries(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createTestItem(
            input: .init(
                date: shiftedDate("2024-02-28T15:00:00Z"),  // JST: 2024-02-29 00:00
                content: "EarlyMar",
                income: 300,
                outgo: 50,
                category: "TZTest",
                priority: 0
            )
        )
        _ = try createTestItem(
            input: .init(
                date: shiftedDate("2024-02-28T14:00:00Z"),  // JST: 2024-02-28 23:00
                content: "LateFeb",
                income: 500,
                outgo: 100,
                category: "TZTest",
                priority: 0
            )
        )

        try ItemBalanceOperations.recalculate(
            context: context,
            date: isoDate("2024-02-01T00:00:00Z")
        )
        let items = try context.fetch(.items(.all))

        #expect(items[0].content == "LateFeb")
        #expect(items[0].balance == 650)
        #expect(items[1].content == "EarlyMar")
        #expect(items[1].balance == 250)
    }
}
