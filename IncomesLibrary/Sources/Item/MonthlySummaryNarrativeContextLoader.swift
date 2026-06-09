import Foundation
import SwiftData

/// Loads monthly summary narrative context from persisted items.
public enum MonthlySummaryNarrativeContextLoader {
    /// Loading failures for monthly summary narrative context.
    public enum LoadingError: Error, Equatable {
        /// The requested date could not be represented as a supported year and month.
        case invalidYearMonth
    }

    /// Default number of category comparison rows included in summary context.
    public static let defaultCategoryComparisonLimit = 8

    /// Loads the current month, previous month, and category comparison context.
    public static func load(
        context: ModelContext,
        date: Date,
        currencyCode: String,
        categoryComparisonLimit: Int = defaultCategoryComparisonLimit
    ) throws -> MonthlySummaryNarrativeBuilder.Context {
        let currentYearMonth = try yearMonth(from: date)
        let previousDate = Calendar.utc.date(byAdding: .month, value: -1, to: date) ?? date
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
            MonthlySummaryNarrativeBuilder.CategoryComparison(
                category: comparison.category,
                currentIncome: comparison.currentIncome,
                previousIncome: comparison.previousIncome,
                incomeDelta: comparison.incomeDelta,
                currentOutgo: comparison.currentOutgo,
                previousOutgo: comparison.previousOutgo,
                outgoDelta: comparison.outgoDelta
            )
        }

        return .init(
            currentTotals: .init(
                year: currentYearMonth.year,
                month: currentYearMonth.month,
                currencyCode: currencyCode,
                totalIncome: currentTotals.totalIncome,
                totalOutgo: currentTotals.totalOutgo,
                netIncome: currentTotals.netIncome
            ),
            previousTotals: .init(
                year: previousYearMonth.year,
                month: previousYearMonth.month,
                currencyCode: currencyCode,
                totalIncome: previousTotals.totalIncome,
                totalOutgo: previousTotals.totalOutgo,
                netIncome: previousTotals.netIncome
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
              (1...9_999).contains(year), // swiftlint:disable:this no_magic_numbers
              (1...12).contains(month) else { // swiftlint:disable:this no_magic_numbers
            throw LoadingError.invalidYearMonth
        }
        return (year, month)
    }
}
