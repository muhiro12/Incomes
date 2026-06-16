import Foundation
import SwiftData

/// Loads monthly summary narrative context from persisted items.
enum MonthlySummaryNarrativeContextLoader {
    typealias LoadingError = MonthlySummaryOperations.LoadingError

    /// Default number of category comparison rows included in summary context.
    static let defaultCategoryComparisonLimit =
        MonthlySummaryOperations.defaultCategoryComparisonLimit

    /// Loads the current month, previous month, and category comparison context.
    static func load(
        context: ModelContext,
        date: Date,
        currencyCode: String,
        categoryComparisonLimit: Int = defaultCategoryComparisonLimit
    ) throws -> MonthlySummaryOperations.Context {
        let currentYearMonth = try yearMonth(from: date)
        let previousDate = MonthlySummaryDateSupport.previousMonthDate(from: date)
        let previousYearMonth = try yearMonth(from: previousDate)
        let currentTotals = try SummaryCalculator.monthlyTotals(
            context: context,
            date: date
        )
        let previousTotals = try SummaryCalculator.monthlyTotals(
            context: context,
            date: previousDate
        )
        let categoryComparisons = try SummaryCalculator.categoryComparison(
            context: context,
            date: date
        )
        .prefix(max(.zero, categoryComparisonLimit))
        .map { comparison in
            MonthlySummaryOperations.CategoryComparison(
                category: comparison.category,
                currentIncome: comparison.currentIncome,
                previousIncome: comparison.previousIncome,
                currentOutgo: comparison.currentOutgo,
                previousOutgo: comparison.previousOutgo
            )
        }

        return .init(
            currentTotals: .init(
                year: currentYearMonth.year,
                month: currentYearMonth.month,
                currencyCode: currencyCode,
                totalIncome: currentTotals.totalIncome,
                totalOutgo: currentTotals.totalOutgo
            ),
            previousTotals: .init(
                year: previousYearMonth.year,
                month: previousYearMonth.month,
                currencyCode: currencyCode,
                totalIncome: previousTotals.totalIncome,
                totalOutgo: previousTotals.totalOutgo
            ),
            categoryComparisons: Array(categoryComparisons)
        )
    }

    /// Builds current month, previous month, and category comparison context from provided items.
    static func load(
        currentItems: [Item],
        previousItems: [Item],
        date: Date,
        currencyCode: String,
        categoryComparisonLimit: Int = defaultCategoryComparisonLimit
    ) throws -> MonthlySummaryOperations.Context {
        let currentYearMonth = try yearMonth(from: date)
        let previousDate = MonthlySummaryDateSupport.previousMonthDate(from: date)
        let previousYearMonth = try yearMonth(from: previousDate)
        let currentTotals = SummaryCalculator.monthlyTotals(for: currentItems)
        let previousTotals = SummaryCalculator.monthlyTotals(for: previousItems)
        let categoryComparisons = SummaryCalculator.categoryComparison(
            currentItems: currentItems,
            previousItems: previousItems
        )
        .prefix(max(.zero, categoryComparisonLimit))
        .map { comparison in
            MonthlySummaryOperations.CategoryComparison(
                category: comparison.category,
                currentIncome: comparison.currentIncome,
                previousIncome: comparison.previousIncome,
                currentOutgo: comparison.currentOutgo,
                previousOutgo: comparison.previousOutgo
            )
        }

        return .init(
            currentTotals: .init(
                year: currentYearMonth.year,
                month: currentYearMonth.month,
                currencyCode: currencyCode,
                totalIncome: currentTotals.totalIncome,
                totalOutgo: currentTotals.totalOutgo
            ),
            previousTotals: .init(
                year: previousYearMonth.year,
                month: previousYearMonth.month,
                currencyCode: currencyCode,
                totalIncome: previousTotals.totalIncome,
                totalOutgo: previousTotals.totalOutgo
            ),
            categoryComparisons: Array(categoryComparisons)
        )
    }
}

private extension MonthlySummaryNarrativeContextLoader {
    static func yearMonth(from date: Date) throws -> (year: Int, month: Int) {
        let components = Calendar.utc.dateComponents([.year, .month], from: date)
        guard let year = components.year,
              let month = components.month,
              YearMonthComponentRules.isValidYear(year),
              YearMonthComponentRules.isValidMonth(month) else {
            throw LoadingError.invalidYearMonth
        }
        return (year, month)
    }
}
