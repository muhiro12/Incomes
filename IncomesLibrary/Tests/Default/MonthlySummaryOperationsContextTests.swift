import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct MonthlySummaryOperationsContextTests {
    private enum FallbackScenario {
        static let previousWorkIncome: Decimal = 80_000
        static let previousFoodOutgo: Decimal = 20_000
        static let currentIncome: Decimal = 100_000
        static let currentOutgo: Decimal = 35_000
        static let currentNetIncome: Decimal = 65_000
        static let workDelta: Decimal = 20_000
        static let foodDelta: Decimal = 15_000
    }

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

    @Test
    func load_matches_current_month_chart_totals_for_fallback_summary() throws {
        try createFallbackSummaryScenario()
        let date = shiftedDate("2026-06-15T00:00:00Z")
        let currentItems = try ItemQueryOperations.items(context: context, date: date)
        let narrativeContext = try MonthlySummaryOperations.loadContext(
            context: context,
            date: date,
            currencyCode: "JPY"
        )
        let summary = MonthlySummaryOperations.fallbackSummary(
            monthTitle: "2026年6月",
            context: narrativeContext,
            locale: Locale(identifier: "ja_JP")
        )

        #expect(ItemSummaryOperations.totalIncome(for: currentItems) == FallbackScenario.currentIncome)
        #expect(ItemSummaryOperations.totalOutgo(for: currentItems) == FallbackScenario.currentOutgo)
        #expect(narrativeContext.currentTotals.totalIncome == FallbackScenario.currentIncome)
        #expect(narrativeContext.currentTotals.totalOutgo == FallbackScenario.currentOutgo)
        #expect(narrativeContext.currentTotals.netIncome == FallbackScenario.currentNetIncome)
        #expect(ItemSummaryOperations.incomeSegments(for: currentItems).map(\.title) == ["Work"])
        #expect(ItemSummaryOperations.outgoSegments(for: currentItems).map(\.title) == ["Food"])
        #expect(narrativeContext.categoryComparisons.map(\.category) == ["Work", "Food"])
        #expect(narrativeContext.categoryComparisons.map(\.incomeDelta) == [FallbackScenario.workDelta, .zero])
        #expect(narrativeContext.categoryComparisons.map(\.outgoDelta) == [.zero, FallbackScenario.foodDelta])
        #expect(summary.contains("2026年6月の収入は¥100,000でした"))
        #expect(summary.contains("支出は¥35,000で、収支は¥65,000でした"))
        #expect(summary.contains("Workの収入が増えました"))
        #expect(summary.contains("Foodの支出が増えました"))
    }

    @Test
    func context_uses_provided_current_items_for_screen_consistency() throws {
        let selectedItem = try createSummaryItem(
            date: "2026-06-05T00:00:00Z",
            content: "Displayed salary",
            income: 100_000,
            outgo: .zero,
            category: "Work"
        )
        _ = try createSummaryItem(
            date: "2026-06-06T00:00:00Z",
            content: "Same-month item outside displayed selection",
            income: 900_000,
            outgo: .zero,
            category: "Other"
        )
        let previousItem = try createSummaryItem(
            date: "2026-05-05T00:00:00Z",
            content: "Previous salary",
            income: 80_000,
            outgo: .zero,
            category: "Work"
        )

        let narrativeContext = try MonthlySummaryOperations.context(
            currentItems: [selectedItem],
            previousItems: [previousItem],
            date: shiftedDate("2026-06-15T00:00:00Z"),
            currencyCode: "JPY"
        )

        #expect(narrativeContext.currentTotals.totalIncome == 100_000)
        #expect(narrativeContext.currentTotals.totalOutgo == .zero)
        #expect(narrativeContext.currentTotals.netIncome == 100_000)
        #expect(narrativeContext.categoryComparisons.map(\.category) == ["Work"])
        #expect(narrativeContext.categoryComparisons.first?.incomeDelta == 20_000)
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

    func createFallbackSummaryScenario() throws {
        _ = try createSummaryItem(
            date: "2026-05-05T00:00:00Z",
            content: "Previous salary",
            income: FallbackScenario.previousWorkIncome,
            outgo: .zero,
            category: "Work"
        )
        _ = try createSummaryItem(
            date: "2026-05-12T00:00:00Z",
            content: "Previous groceries",
            income: .zero,
            outgo: FallbackScenario.previousFoodOutgo,
            category: "Food"
        )
        _ = try createSummaryItem(
            date: "2026-06-05T00:00:00Z",
            content: "Current salary",
            income: FallbackScenario.currentIncome,
            outgo: .zero,
            category: "Work"
        )
        _ = try createSummaryItem(
            date: "2026-06-12T00:00:00Z",
            content: "Current groceries",
            income: .zero,
            outgo: FallbackScenario.currentOutgo,
            category: "Food"
        )
    }
}
