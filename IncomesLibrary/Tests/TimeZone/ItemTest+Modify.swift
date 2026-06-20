import Foundation
@testable import IncomesLibrary
import Testing

extension ItemTest {
    // MARK: - Modify

    @Test("modify updates values and regenerates tags with UTC-normalized date")
    func modifyUpdatesValuesAndRegeneratesTags() throws {
        let item = try Item.create(
            context: context,
            values: .init(
                date: shiftedDate("2024-01-01T00:00:00Z"),
                content: "Old",
                income: 100,
                outgo: 0,
                category: "Misc",
                priority: 0
            ),
            repeatID: UUID()
        )

        let newDate = shiftedDate("2024-04-01T00:00:00Z")
        try item.modify(
            values: .init(
                date: newDate,
                content: "Updated",
                income: 200,
                outgo: 50,
                category: "Update",
                priority: 0
            ),
            repeatID: UUID()
        )

        #expect(item.utcDate == isoDate("2024-04-01T00:00:00Z"))
        #expect(item.content == "Updated")
        #expect(item.income == 200)
        #expect(item.outgo == 50)
        #expect(item.tags?.contains { tag in
            tag.name == "202404"
        } == true)
    }

    @Test(
        "modify normalizes JST date to UTC start of day",
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
    func modifyNormalizesJSTDateToUTCStartOfDay(date: Date, expected: Date) throws {
        TimeZone.ReferenceType.default = try #require(
            TimeZone(identifier: "Asia/Tokyo")
        )

        let item = try Item.create(
            context: context,
            values: .init(
                date: shiftedDate("2024-01-01T00:00:00Z"),
                content: "Initial",
                income: 0,
                outgo: 0,
                category: "Init",
                priority: 0
            ),
            repeatID: UUID()
        )

        try item.modify(
            values: .init(
                date: date,
                content: "Updated",
                income: 100,
                outgo: 50,
                category: "Updated",
                priority: 0
            ),
            repeatID: item.repeatID
        )

        #expect(item.utcDate == expected)
    }

    @Test("modify preserves repeatID if reassigned to same value", arguments: timeZones)
    func modifyPreservesRepeatIDIfSame(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let repeatID = UUID()
        let item = try Item.create(
            context: context,
            values: .init(
                date: shiftedDate("2024-02-01T00:00:00Z"),
                content: "Init",
                income: 0,
                outgo: 0,
                category: "Start",
                priority: 0
            ),
            repeatID: repeatID
        )

        try item.modify(
            values: .init(
                date: shiftedDate("2024-02-02T00:00:00Z"),
                content: "Changed",
                income: 500,
                outgo: 200,
                category: "Updated",
                priority: 0
            ),
            repeatID: repeatID
        )

        #expect(item.repeatID == repeatID)
        #expect(item.tags?.contains { tag in
            tag.name == "202402"
        } == true)
    }

    @Test("modify updates date to correct UTC startOfDay", arguments: timeZones)
    func modifyUpdatesDateToUTCDayStart(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let item = try Item.create(
            context: context,
            values: .init(
                date: shiftedDate("2024-07-01T10:00:00Z"),
                content: "Init",
                income: 0,
                outgo: 0,
                category: "Tag",
                priority: 0
            ),
            repeatID: UUID()
        )

        let updatedDate = shiftedDate("2024-07-15T23:59:59Z")
        try item.modify(
            values: .init(
                date: updatedDate,
                content: item.content,
                income: item.income,
                outgo: item.outgo,
                category: "Tag",
                priority: 0
            ),
            repeatID: item.repeatID
        )

        #expect(item.utcDate == isoDate("2024-07-15T00:00:00Z"))
    }
}
