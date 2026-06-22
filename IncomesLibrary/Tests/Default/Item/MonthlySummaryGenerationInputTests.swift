import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct MonthlySummaryGenerationInputTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func init_builds_snapshots_from_current_and_previous_items() throws {
        let currentItem = try createSummaryItem(
            date: "2024-06-10T00:00:00Z",
            content: "Salary",
            income: 1_000,
            outgo: .zero,
            category: "Work"
        )
        let previousItem = try createSummaryItem(
            date: "2024-05-15T00:00:00Z",
            content: "Rent",
            income: .zero,
            outgo: 400,
            category: "Housing"
        )

        let input = MonthlySummaryGenerationInput(
            currentItems: [currentItem],
            previousItems: [previousItem],
            currencyCode: "JPY",
            localeIdentifier: "ja_JP"
        )

        #expect(input.currencyCode == "JPY")
        #expect(input.localeIdentifier == "ja_JP")
        #expect(input.snapshots.map(\.content) == ["Salary", "Rent"])
        #expect(input.snapshots.map(\.category) == ["Work", "Housing"])
    }

    @Test
    func init_maps_missing_category_to_others_snapshot() throws {
        let item = try createSummaryItem(
            date: "2024-06-10T00:00:00Z",
            content: "Adjustment",
            income: .zero,
            outgo: 100,
            category: "Temporary"
        )
        item.modify(
            tags: (item.tags ?? []).filter { tag in
                tag.type != .category
            }
        )

        let input = MonthlySummaryGenerationInput(
            currentItems: [item],
            previousItems: [],
            currencyCode: "USD",
            localeIdentifier: "en_US"
        )

        let snapshot = try #require(input.snapshots.first)
        #expect(snapshot.category == CategoryNameSupport.displayName(forStoredName: nil))
    }
}

private extension MonthlySummaryGenerationInputTests {
    @discardableResult
    func createSummaryItem(
        date: String,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String
    ) throws -> Item {
        try createItem(
            context: context,
            input: .init(
                date: shiftedDate(date),
                content: content,
                income: income,
                outgo: outgo,
                category: category,
                priority: 0
            ),
            repeatCount: 1
        )
    }
}
