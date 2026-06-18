import Foundation
import SwiftData

/// Shared monthly summary operations used by app and intent surfaces.
public enum MonthlySummaryOperations {
    /// Data needed to build a monthly narrative prompt or deterministic fallback.
    public struct Context: Equatable, Sendable {
        /// Totals for the requested month.
        public let currentTotals: MonthTotals
        /// Totals for the previous month.
        public let previousTotals: MonthTotals
        /// Category-level comparisons sorted by significance.
        public let categoryComparisons: [CategoryComparison]

        /// Creates a monthly narrative context.
        public init(
            currentTotals: MonthTotals,
            previousTotals: MonthTotals,
            categoryComparisons: [CategoryComparison]
        ) {
            self.currentTotals = currentTotals
            self.previousTotals = previousTotals
            self.categoryComparisons = categoryComparisons
        }
    }

    /// Monthly totals prepared for narrative generation.
    public struct MonthTotals: Equatable, Sendable {
        /// The calendar year for the month.
        public let year: Int
        /// The one-based month number.
        public let month: Int
        /// The currency code selected by the app.
        public let currencyCode: String
        /// Total income for the month.
        public let totalIncome: Decimal
        /// Total outgo for the month.
        public let totalOutgo: Decimal
        /// Net income for the month.
        public let netIncome: Decimal

        /// Creates monthly totals prepared for narrative generation.
        public init(
            year: Int,
            month: Int,
            currencyCode: String,
            totalIncome: Decimal,
            totalOutgo: Decimal
        ) {
            self.year = year
            self.month = month
            self.currencyCode = currencyCode
            self.totalIncome = totalIncome
            self.totalOutgo = totalOutgo
            netIncome = totalIncome - totalOutgo
        }
    }

    /// Category comparison data prepared for narrative generation.
    public struct CategoryComparison: Equatable, Sendable {
        /// The category display name.
        public let category: String
        /// Current-month income total for this category.
        public let currentIncome: Decimal
        /// Previous-month income total for this category.
        public let previousIncome: Decimal
        /// Current income minus previous income for this category.
        public let incomeDelta: Decimal
        /// Current-month outgo total for this category.
        public let currentOutgo: Decimal
        /// Previous-month outgo total for this category.
        public let previousOutgo: Decimal
        /// Current outgo minus previous outgo for this category.
        public let outgoDelta: Decimal

        /// Creates category comparison data prepared for narrative generation.
        public init(
            category: String,
            currentIncome: Decimal,
            previousIncome: Decimal,
            currentOutgo: Decimal,
            previousOutgo: Decimal
        ) {
            self.category = category
            self.currentIncome = currentIncome
            self.previousIncome = previousIncome
            incomeDelta = currentIncome - previousIncome
            self.currentOutgo = currentOutgo
            self.previousOutgo = previousOutgo
            outgoDelta = currentOutgo - previousOutgo
        }
    }

    /// Validation failures for generated monthly summary text.
    public enum ValidationError: Error, Equatable {
        /// The generated text was empty.
        case emptySummary
        /// The generated text contained a value that was not allowed.
        case unsupportedNumber
        /// The generated text exposed prompt internals or implementation labels.
        case unsupportedContent
    }

    /// Loading failures for monthly summary context.
    public enum LoadingError: Error, Equatable {
        /// The requested date could not be represented as a supported year and month.
        case invalidYearMonth
    }

    /// Default number of category comparison rows included in summary context.
    public static let defaultCategoryComparisonLimit = 8

    /// Returns a date in the month before `date` using the UTC calendar.
    public static func previousMonthDate(from date: Date) -> Date {
        MonthlySummaryDateSupport.previousMonthDate(from: date)
    }

    /// Returns the language code used for monthly summary prompts.
    public static func languageCode(for locale: Locale) -> String {
        LocaleLanguageCodeSupport.code(for: locale)
    }

    /// Loads the current month, previous month, and category comparison context.
    public static func loadContext(
        context: ModelContext,
        date: Date,
        currencyCode: String,
        categoryComparisonLimit: Int = defaultCategoryComparisonLimit
    ) throws -> Context {
        try MonthlySummaryNarrativeContextLoader.load(
            context: context,
            date: date,
            currencyCode: currencyCode,
            categoryComparisonLimit: categoryComparisonLimit
        )
    }

    /// Builds monthly summary context from the exact items selected by the caller.
    public static func context(
        currentItems: [Item],
        previousItems: [Item],
        date: Date,
        currencyCode: String,
        categoryComparisonLimit: Int = defaultCategoryComparisonLimit
    ) throws -> Context {
        try MonthlySummaryNarrativeContextLoader.load(
            currentItems: currentItems,
            previousItems: previousItems,
            date: date,
            currencyCode: currencyCode,
            categoryComparisonLimit: categoryComparisonLimit
        )
    }

    /// Builds Foundation Models instructions for monthly summary generation.
    public static func instructions(languageCode: String) -> String {
        MonthlySummaryNarrativeBuilder.instructions(languageCode: languageCode)
    }

    /// Builds a model prompt from deterministic monthly summary context.
    public static func prompt(
        localeIdentifier: String,
        languageCode: String,
        context: Context
    ) -> String {
        MonthlySummaryNarrativeBuilder.prompt(
            localeIdentifier: localeIdentifier,
            languageCode: languageCode,
            context: context
        )
    }

    /// Returns a deterministic fallback summary when model generation cannot be trusted.
    public static func fallbackSummary(
        monthTitle: String,
        context: Context,
        locale: Locale
    ) -> String {
        MonthlySummaryNarrativeBuilder.fallbackSummary(
            monthTitle: monthTitle,
            context: context,
            locale: locale
        )
    }

    /// Trims and validates generated text against the exact current-month totals.
    public static func validatedSummary(
        _ summary: String,
        currentTotals: MonthTotals
    ) throws -> String {
        try MonthlySummaryNarrativeBuilder.validatedSummary(
            summary,
            currentTotals: currentTotals
        )
    }
}
