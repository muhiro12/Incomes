import Foundation
@testable import IncomesLibrary
import Testing

extension ItemOperationsTest {
    // MARK: - Create

    @Test("create item with correct balance", arguments: timeZones)
    func create(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-01-01T00:00:00Z"),
                content: "Lunch",
                income: 1_000,
                outgo: 300,
                category: "Food",
                priority: 0
            )
        )
        let item = try #require(fetchItems(context).first)
        #expect(item.balance == 700)
    }

    @Test("create with repeatCount 3 creates 3 items with same repeatID", arguments: timeZones)
    func createWithRepeat(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-01-01T00:00:00Z"),
                content: "Rent",
                income: 0,
                outgo: 100_000,
                category: "Housing",
                priority: 0
            ),
            repeatCount: 3
        )
        let items = fetchItems(context)
        #expect(items.count == 3)
        #expect(Set(items.map(\.repeatID)).count == 1)
    }

    @Test("create with zero repeatCount still creates one item", arguments: timeZones)
    func createWithZeroRepeat(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-03-01T00:00:00Z"),
                content: "Single",
                income: 100,
                outgo: 50,
                category: "Solo",
                priority: 0
            ),
            repeatCount: 0
        )
        let items = fetchItems(context)
        #expect(items.count == 1)
        #expect(items.first?.content == "Single")
    }

    @Test("create with zero income and outgo results in zero balance", arguments: timeZones)
    func createWithZeroAmounts(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-03-01T00:00:00Z"),
                content: "Neutral",
                income: 0,
                outgo: 0,
                category: "Empty",
                priority: 0
            )
        )
        let item = try #require(fetchItems(context).first)
        #expect(item.balance == 0)
    }

    @Test("create with duplicate category names does not break", arguments: timeZones)
    func createWithDuplicateCategoryNames(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        for _ in 0..<2 {
            _ = try createTestItem(
                input: .init(
                    date: isoDate("2024-03-01T00:00:00Z"),
                    content: "Repeated",
                    income: 100,
                    outgo: 50,
                    category: "Shared",
                    priority: 0
                )
            )
        }
        let items = fetchItems(context)
        #expect(items.count == 2)
        #expect(Set(items.map(\.category?.name)).count == 1)
    }

    @Test("create with end-of-month date generates all repeating items", arguments: timeZones)
    func createEndOfMonthRepeatingItems(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-01-31T00:00:00Z"),
                content: "EndMonth",
                income: 100,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 3
        )
        let items = try context.fetch(.items(.all)).sorted { first, second in
            first.utcDate < second.utcDate
        }
        #expect(items.count == 3)
        let months = items.map { item in
            item.utcDate.stringValueWithoutLocale(.yyyyMM)
        }
        #expect(months == ["202401", "202402", "202403"])
    }

    @Test("create stores date near midnight UTC correctly", arguments: timeZones)
    func createWithMidnightBoundary(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let boundaryDate = shiftedDate("2024-03-15T00:00:00Z")
        let item = try createTestItem(
            input: .init(
                date: boundaryDate,
                content: "MidnightUTC",
                income: 100,
                outgo: 0,
                category: "Test",
                priority: 0
            )
        )
        let found = try #require(try context.fetchFirst(.items(.idIs(item.id))))
        #expect(found.utcDate == isoDate("2024-03-15T00:00:00Z"))
    }

    @Test("create stores JST midnight as UTC start of day", arguments: timeZones)
    func createStoresJSTMidnightAsUTCStartOfDay(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let jstDate = shiftedDate("2024-03-15T09:00:00Z")  // 00:00 UTC
        let item = try createTestItem(
            input: .init(
                date: jstDate,
                content: "JSTToUTC",
                income: 100,
                outgo: 0,
                category: "Test",
                priority: 0
            )
        )
        let found = try #require(try context.fetchFirst(.items(.idIs(item.id))))
        #expect(found.utcDate == isoDate("2024-03-15T00:00:00Z"))
    }

    @Test("create rounds input date to start of day UTC", arguments: timeZones)
    func createRoundsDateToStartOfDay(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let inputDate = isoDate("2024-03-15T10:30:00Z")
        let expectedDate = Calendar.utc.startOfDay(for: inputDate)
        let item = try createTestItem(
            input: .init(
                date: inputDate,
                content: "RoundedTime",
                income: 100,
                outgo: 0,
                category: "Test",
                priority: 0
            )
        )
        let found = try #require(try context.fetchFirst(.items(.idIs(item.id))))
        #expect(found.utcDate == expectedDate)
    }
}
