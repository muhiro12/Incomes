import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct NaturalLanguageSearchQueryTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test("Out-of-range requested limits remain bounded")
    func requested_limits_are_bounded() throws {
        _ = try makeFixture()
        let conditions = ItemSearchConditions(content: "rent")
        let minimum = try NaturalLanguageSearchOperations.results(
            context: context, conditions: conditions, limit: -1
        )
        #expect(minimum.items.count == 1)
        #expect(minimum.hasMoreItems)
        let descriptor = NaturalLanguageSearchOperations.resultDescriptor(
            for: conditions, limit: .max
        )
        #expect(descriptor.fetchLimit == NaturalLanguageSearchOperations.resultLimit + 1)
    }

    @Test("Month and content conditions return only matching saved items")
    func month_and_content_match() throws {
        let fixture = try makeFixture()

        let results = try NaturalLanguageSearchOperations.results(
            context: context,
            conditions: .init(
                period: .init(year: 2_026, month: 10),
                content: "rent"
            )
        )

        #expect(Set(results.items.map(\.persistentModelID)) == [
            fixture.octoberRent.persistentModelID,
            fixture.octoberLastDayRent.persistentModelID
        ])
        #expect(results.hasMoreItems == false)
    }

    @Test("Japanese content matches literally within the month")
    func japanese_content_match() throws {
        let fixture = try makeFixture()

        let results = try NaturalLanguageSearchOperations.results(
            context: context,
            conditions: .init(
                period: .init(year: 2_026, month: 10),
                content: "家賃"
            )
        )

        #expect(results.items.map(\.persistentModelID) == [
            fixture.octoberJapaneseRent.persistentModelID
        ])
    }

    @Test("Income and outgo bounds are inclusive and combine with AND")
    func amount_bounds_are_inclusive_and_combined() throws {
        let fixture = try makeFixture()

        let outgoResults = try NaturalLanguageSearchOperations.results(
            context: context,
            conditions: .init(
                period: .init(year: 2_026, month: 10),
                outgo: .init(minimum: 80_000, maximum: 85_000)
            )
        )
        let incomeResults = try NaturalLanguageSearchOperations.results(
            context: context,
            conditions: .init(
                income: .init(minimum: 300_000, maximum: nil)
            )
        )
        let signedResults = try NaturalLanguageSearchOperations.results(
            context: context,
            conditions: .init(
                income: .init(minimum: -500, maximum: -500)
            )
        )

        #expect(Set(outgoResults.items.map(\.persistentModelID)) == [
            fixture.octoberRent.persistentModelID,
            fixture.octoberJapaneseRent.persistentModelID
        ])
        #expect(incomeResults.items.map(\.persistentModelID) == [
            fixture.octoberSalary.persistentModelID
        ])
        #expect(signedResults.items.map(\.persistentModelID) == [
            fixture.octoberRefund.persistentModelID
        ])
    }

    @Test("Validated model output queries the expected saved items end to end")
    func validated_extraction_queries_expected_items() throws {
        let fixture = try makeFixture()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "Asia/Tokyo"))

        let conditions = try NaturalLanguageSearchOperations.conditions(
            from: .init(relativeMonthOffset: 1, content: "家賃"),
            request: "来月の家賃",
            currentDate: isoDate("2026-09-15T03:00:00Z"),
            calendar: calendar
        )
        let results = try NaturalLanguageSearchOperations.results(
            context: context,
            conditions: conditions
        )

        #expect(results.items.map(\.persistentModelID) == [
            fixture.octoberJapaneseRent.persistentModelID
        ])
    }

    @Test("Results are limited and report additional matches without totals")
    func results_are_limited() throws {
        _ = try makeFixture()

        let results = try NaturalLanguageSearchOperations.results(
            context: context,
            conditions: .init(period: .init(year: 2_026, month: 10)),
            limit: 2
        )

        #expect(results.items.count == 2)
        #expect(results.hasMoreItems)
        #expect(results.items.map(\.content) == ["Parking rent", "Salary"])
    }

    @Test("Searching reads the store without pending changes")
    func search_is_read_only() throws {
        _ = try makeFixture()
        try context.save()
        let countBefore = try ItemQueryOperations.allItemsCount(context: context)

        _ = try NaturalLanguageSearchOperations.results(
            context: context,
            conditions: .init(content: "Rent")
        )

        #expect(context.hasChanges == false)
        #expect(try ItemQueryOperations.allItemsCount(context: context) == countBefore)
    }

    @Test("A deleted item disappears from a repeated search")
    func deleted_item_disappears_on_refresh() throws {
        let fixture = try makeFixture()
        let conditions = ItemSearchConditions(
            period: .init(year: 2_026, month: 10),
            content: "rent"
        )

        try ItemDeletionOperations.delete(
            context: context,
            item: fixture.octoberRent
        )
        let results = try NaturalLanguageSearchOperations.results(
            context: context,
            conditions: conditions
        )

        #expect(results.items.map(\.persistentModelID) == [
            fixture.octoberLastDayRent.persistentModelID
        ])
    }
}

private extension NaturalLanguageSearchQueryTests {
    struct Fixture {
        let septemberRent: Item
        let octoberRent: Item
        let octoberJapaneseRent: Item
        let octoberSalary: Item
        let octoberRefund: Item
        let octoberLastDayRent: Item
        let novemberRent: Item
    }

    // Synthetic values deliberately cover distinct inclusive range boundaries.
    // swiftlint:disable no_magic_numbers
    func makeFixture() throws -> Fixture {
        .init(
            septemberRent: try makeItem("2026-09-30T12:00:00Z", "Rent", outgo: 80_000),
            octoberRent: try makeItem("2026-10-01T00:00:00Z", "Rent", outgo: 80_000),
            octoberJapaneseRent: try makeItem("2026-10-20T12:00:00Z", "家賃", outgo: 85_000),
            octoberSalary: try makeItem("2026-10-25T12:00:00Z", "Salary", income: 300_000),
            octoberRefund: try makeItem("2026-10-15T12:00:00Z", "Refund", income: -500),
            octoberLastDayRent: try makeItem("2026-10-31T23:00:00Z", "Parking rent", outgo: 5_000),
            novemberRent: try makeItem("2026-11-01T00:00:00Z", "Rent", outgo: 80_000)
        )
    }

    // swiftlint:enable no_magic_numbers

    func makeItem(
        _ dateString: String,
        _ content: String,
        income: Decimal = .zero,
        outgo: Decimal = .zero
    ) throws -> Item {
        try createItem(
            context: context,
            input: .init(
                date: shiftedDate(dateString),
                content: content,
                income: income,
                outgo: outgo,
                category: "Synthetic",
                priority: 0
            )
        )
    }
}
