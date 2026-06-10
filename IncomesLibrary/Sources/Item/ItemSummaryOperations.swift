import Foundation
import SwiftData

/// Shared item reporting operations used by app, widget, and intent surfaces.
public enum ItemSummaryOperations {
    /// A value type that represents monthly totals.
    public struct MonthlyTotals: Sendable {
        /// Sum of all item incomes within the target month.
        public let totalIncome: Decimal
        /// Sum of all item outgo amounts within the target month.
        public let totalOutgo: Decimal
        /// Convenience value: `totalIncome - totalOutgo`.
        public let netIncome: Decimal

        /// Creates a new `MonthlyTotals` value.
        public init(totalIncome: Decimal, totalOutgo: Decimal) {
            self.totalIncome = totalIncome
            self.totalOutgo = totalOutgo
            netIncome = totalIncome - totalOutgo
        }
    }

    /// A value type that compares category totals between two months.
    public struct CategoryComparison: Sendable {
        /// The display name of the category.
        public let category: String
        /// Current-month income total for the category.
        public let currentIncome: Decimal
        /// Previous-month income total for the category.
        public let previousIncome: Decimal
        /// Convenience value: `currentIncome - previousIncome`.
        public let incomeDelta: Decimal
        /// Current-month outgo total for the category.
        public let currentOutgo: Decimal
        /// Previous-month outgo total for the category.
        public let previousOutgo: Decimal
        /// Convenience value: `currentOutgo - previousOutgo`.
        public let outgoDelta: Decimal

        /// Creates a new category comparison value.
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

    /// A value type that represents one category segment in a chart.
    public struct ChartSegment: Equatable, Sendable {
        /// The display name of the category.
        public let title: String
        /// Aggregated amount for the category.
        public let value: Decimal
        /// `value` converted to `Double` for chart plotting.
        public let plotValue: Double
        /// Share of the category value within the total.
        public let ratio: Double
        /// Localized percentage text for `ratio`.
        public let percentText: String
        /// Legend label combining category, percentage, and amount.
        public let label: String

        /// Creates a new category chart segment.
        public init(
            title: String,
            value: Decimal,
            ratio: Double
        ) {
            self.title = title
            self.value = value
            plotValue = Self.decimalToDouble(value)
            self.ratio = ratio
            percentText = ratio.formatted(.percent.precision(.fractionLength(0)))
            label = "\(title) \(percentText) • \(value.asCurrency)"
        }

        private static func decimalToDouble(_ value: Decimal) -> Double {
            Double(value.description) ?? .zero
        }
    }

    /// Calculates totals for the month that contains `date`.
    public static func monthlyTotals(
        context: ModelContext,
        date: Date
    ) throws -> MonthlyTotals {
        try SummaryCalculator.monthlyTotals(
            context: context,
            date: date
        )
    }

    /// Compares category totals for the month containing `date`.
    public static func categoryComparison(
        context: ModelContext,
        date: Date
    ) throws -> [CategoryComparison] {
        try SummaryCalculator.categoryComparison(
            context: context,
            date: date
        )
    }

    /// Returns total income for the provided items.
    public static func totalIncome(for items: [Item]) -> Decimal {
        SummaryCalculator.totalIncome(for: items)
    }

    /// Returns total outgo for the provided items.
    public static func totalOutgo(for items: [Item]) -> Decimal {
        SummaryCalculator.totalOutgo(for: items)
    }

    /// Returns income chart segments grouped by category.
    public static func incomeSegments(for items: [Item]) -> [ChartSegment] {
        CategoryChartSummaryCalculator.incomeSegments(for: items)
    }

    /// Returns outgo chart segments grouped by category.
    public static func outgoSegments(for items: [Item]) -> [ChartSegment] {
        CategoryChartSummaryCalculator.outgoSegments(for: items)
    }
}
