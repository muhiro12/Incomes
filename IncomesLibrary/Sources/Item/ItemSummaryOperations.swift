import Foundation
import SwiftData

/// Shared item reporting operations used by app, widget, and intent surfaces.
public enum ItemSummaryOperations {
    /// Shared presentation rule for net income across app surfaces.
    public enum NetIncomePresentation: Equatable, Sendable {
        /// Net income is strictly greater than zero.
        case positive
        /// Net income is exactly zero.
        case neutral
        /// Net income is strictly less than zero.
        case negative

        /// Symbol every surface uses for this direction, so the shape never differs.
        public var symbolName: String {
            switch self {
            case .positive:
                "chevron.up"
            case .neutral:
                "minus"
            case .negative:
                "chevron.down"
            }
        }
    }

    /// A value type that represents monthly totals.
    public struct MonthlyTotals: Sendable {
        /// Sum of all item incomes within the target month.
        public let totalIncome: Decimal
        /// Sum of all item outgo amounts within the target month.
        public let totalOutgo: Decimal
        /// Convenience value: `totalIncome - totalOutgo`.
        public let netIncome: Decimal

        /// Creates a new `MonthlyTotals` value.
        /// - Throws: `ItemAmountError.totalOutOfRange` when the net income is not exact.
        public init(totalIncome: Decimal, totalOutgo: Decimal) throws {
            self.totalIncome = totalIncome
            self.totalOutgo = totalOutgo
            netIncome = try ExactAmountArithmetic.checkedDifference(totalIncome, totalOutgo)
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
        /// - Throws: `ItemAmountError.totalOutOfRange` when a delta is not exact.
        public init(
            category: String,
            currentIncome: Decimal,
            previousIncome: Decimal,
            currentOutgo: Decimal,
            previousOutgo: Decimal
        ) throws {
            self.category = category
            self.currentIncome = currentIncome
            self.previousIncome = previousIncome
            incomeDelta = try ExactAmountArithmetic.checkedDifference(currentIncome, previousIncome)
            self.currentOutgo = currentOutgo
            self.previousOutgo = previousOutgo
            outgoDelta = try ExactAmountArithmetic.checkedDifference(currentOutgo, previousOutgo)
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

    /// Placeholder shown instead of an amount that cannot be calculated exactly.
    ///
    /// Surfaces pair it with `ItemAmountError.totalOutOfRange` for assistive
    /// technologies, so a refused total is never displayed as zero.
    public static let unavailableAmountText = "—"

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
    /// - Throws: `ItemAmountError.totalOutOfRange` when the total is not exact.
    public static func totalIncome(for items: [Item]) throws -> Decimal {
        try SummaryCalculator.totalIncome(for: items)
    }

    /// Returns total outgo for the provided items.
    /// - Throws: `ItemAmountError.totalOutOfRange` when the total is not exact.
    public static func totalOutgo(for items: [Item]) throws -> Decimal {
        try SummaryCalculator.totalOutgo(for: items)
    }

    /// Returns exact totals for the provided items.
    /// - Throws: `ItemAmountError.totalOutOfRange` when a total or the net income is not exact.
    public static func totals(for items: [Item]) throws -> MonthlyTotals {
        try SummaryCalculator.monthlyTotals(for: items)
    }

    /// Classifies net income for consistent colors, symbols, and labels.
    public static func netIncomePresentation(
        for netIncome: Decimal
    ) -> NetIncomePresentation {
        if netIncome > .zero {
            return .positive
        }
        if netIncome < .zero {
            return .negative
        }
        return .neutral
    }

    /// Returns income chart segments grouped by category.
    /// - Throws: `ItemAmountError.totalOutOfRange` when a category total is not exact.
    public static func incomeSegments(for items: [Item]) throws -> [ChartSegment] {
        try CategoryChartSummaryCalculator.incomeSegments(for: items)
    }

    /// Returns outgo chart segments grouped by category.
    /// - Throws: `ItemAmountError.totalOutOfRange` when a category total is not exact.
    public static func outgoSegments(for items: [Item]) throws -> [ChartSegment] {
        try CategoryChartSummaryCalculator.outgoSegments(for: items)
    }
}
