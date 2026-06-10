import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct MonthlySummaryOperationsContextTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func load_builds_current_previous_and_comparison_context() throws {
        _ = try createSummaryItem(
            date: "2023-12-10T00:00:00Z",
            content: "December salary",
            income: 700,
            outgo: .zero,
            category: "Work"
        )
        _ = try createSummaryItem(
            date: "2024-01-08T00:00:00Z",
            content: "January salary",
            income: 900,
            outgo: .zero,
            category: "Work"
        )
        _ = try createSummaryItem(
            date: "2024-01-12T00:00:00Z",
            content: "Rent",
            income: .zero,
            outgo: 400,
            category: "Housing"
        )

        let narrativeContext = try MonthlySummaryOperations.loadContext(
            context: context,
            date: shiftedDate("2024-01-15T00:00:00Z"),
            currencyCode: "JPY"
        )

        #expect(narrativeContext.currentTotals.year == 2_024)
        #expect(narrativeContext.currentTotals.month == 1)
        #expect(narrativeContext.currentTotals.currencyCode == "JPY")
        #expect(narrativeContext.currentTotals.totalIncome == 900)
        #expect(narrativeContext.currentTotals.totalOutgo == 400)
        #expect(narrativeContext.currentTotals.netIncome == 500)
        #expect(narrativeContext.previousTotals.year == 2_023)
        #expect(narrativeContext.previousTotals.month == 12)
        #expect(narrativeContext.previousTotals.totalIncome == 700)
        #expect(narrativeContext.previousTotals.totalOutgo == .zero)

        let workComparison = try #require(
            narrativeContext.categoryComparisons.first { comparison in
                comparison.category == "Work"
            }
        )
        #expect(workComparison.currentIncome == 900)
        #expect(workComparison.previousIncome == 700)
        #expect(workComparison.incomeDelta == 200)
    }

    @Test
    func load_limits_category_comparisons() throws {
        _ = try createSummaryItem(
            date: "2024-02-01T00:00:00Z",
            content: "Large",
            income: .zero,
            outgo: 300,
            category: "Large"
        )
        _ = try createSummaryItem(
            date: "2024-02-02T00:00:00Z",
            content: "Medium",
            income: .zero,
            outgo: 200,
            category: "Medium"
        )
        _ = try createSummaryItem(
            date: "2024-02-03T00:00:00Z",
            content: "Small",
            income: .zero,
            outgo: 100,
            category: "Small"
        )

        let narrativeContext = try MonthlySummaryOperations.loadContext(
            context: context,
            date: shiftedDate("2024-02-15T00:00:00Z"),
            currencyCode: "USD",
            categoryComparisonLimit: 2
        )

        #expect(narrativeContext.categoryComparisons.map(\.category) == ["Large", "Medium"])
    }
}

private extension MonthlySummaryOperationsContextTests {
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
            date: shiftedDate(date),
            content: content,
            income: income,
            outgo: outgo,
            category: category,
            priority: 0,
            repeatCount: 1
        )
    }
}
