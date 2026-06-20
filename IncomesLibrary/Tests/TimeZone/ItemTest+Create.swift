import Foundation
@testable import IncomesLibrary
import Testing

extension ItemTest {
    // MARK: - Create

    @Test("create assigns correct values and UTC-normalized date", arguments: timeZones)
    func createAssignsCorrectValuesAndUTCNormalizedDate(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let date = shiftedDate("2024-03-15T10:30:00Z")
        let content = "Lunch"
        let income = Decimal(0)
        let outgo = Decimal(1_200)
        let category = "Food"
        let repeatID = UUID()

        let item = try Item.create(
            context: context,
            values: .init(
                date: date,
                content: content,
                income: income,
                outgo: outgo,
                category: category,
                priority: 0
            ),
            repeatID: repeatID
        )

        #expect(item.utcDate == Calendar.utc.startOfDay(for: date))
        #expect(item.content == content)
        #expect(item.income == income)
        #expect(item.outgo == outgo)
        #expect(item.repeatID == repeatID)
        #expect(item.tags?.contains { tag in
            tag.name == "202403"
        } == true)
    }

    @Test(
        "create normalizes JST date to UTC start of day",
        arguments: [
            ("2023-12-31T23:59:59+0900", "2023-12-31T00:00:00Z"),
            ("2024-01-01T00:00:00+0900", "2024-01-01T00:00:00Z"),
            ("2024-01-01T08:59:59+0900", "2024-01-01T00:00:00Z"),
            ("2024-01-01T09:00:00+0900", "2024-01-01T00:00:00Z"),
            ("2024-01-01T14:59:59+0900", "2024-01-01T00:00:00Z"),
            ("2024-01-01T15:00:00+0900", "2024-01-01T00:00:00Z"),
            ("2024-03-31T23:59:59+0900", "2024-03-31T00:00:00Z"),
            ("2024-04-01T00:00:00+0900", "2024-04-01T00:00:00Z")
        ].map { value in
            (isoDate(value.0), isoDate(value.1))
        }
    )
    func createNormalizesJSTDateToUTCStartOfDay(date: Date, expected: Date) throws {
        TimeZone.ReferenceType.default = try #require(
            TimeZone(identifier: "Asia/Tokyo")
        )

        let item = try Item.create(
            context: context,
            values: .init(
                date: date,
                content: "Check",
                income: .zero,
                outgo: .zero,
                category: "Boundary",
                priority: 0
            ),
            repeatID: UUID()
        )

        #expect(item.utcDate == expected)
    }

    @Test("create assigns default values when optional inputs are minimal")
    func createAssignsDefaultValues() throws {
        let date = shiftedDate("2024-01-01T00:00:00Z")
        let item = try Item.create(
            context: context,
            values: .init(
                date: date,
                content: "",
                income: .zero,
                outgo: .zero,
                category: "",
                priority: 0
            ),
            repeatID: UUID()
        )

        #expect(item.utcDate == isoDate("2024-01-01T00:00:00Z"))
        #expect(item.content.isEmpty)
        #expect(item.income == .zero)
        #expect(item.outgo == .zero)
        #expect(item.tags?.contains { tag in
            tag.name == "202401"
        } == true)
    }

    @Test("create tags contain year, yearMonth, content, and category", arguments: timeZones)
    func createAssignsAllExpectedTags(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let date = shiftedDate("2024-06-10T12:00:00Z")
        let item = try Item.create(
            context: context,
            values: .init(
                date: date,
                content: "Groceries",
                income: .zero,
                outgo: 5_000,
                category: "Daily",
                priority: 0
            ),
            repeatID: UUID()
        )

        let tagNames = item.tags?.map(\.name) ?? []
        #expect(tagNames.contains("2024"))
        #expect(tagNames.contains("202406"))
        #expect(tagNames.contains("Groceries"))
        #expect(tagNames.contains("Daily"))
    }
}
