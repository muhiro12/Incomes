//
//  CategoryChartSummaryCalculator.swift
//  IncomesLibrary
//
//  Builds category summaries for chart-based item reporting.
//

import Foundation

/// Utilities for building category chart summaries without app UI dependencies.
public enum CategoryChartSummaryCalculator {
    /// A value type that represents one category segment in a chart.
    public struct Segment: Equatable, Sendable {
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

    /// Returns income chart segments grouped by category.
    public static func incomeSegments(for items: [Item]) -> [Segment] {
        segments(
            for: items,
            amount: \.income
        )
    }

    /// Returns outgo chart segments grouped by category.
    public static func outgoSegments(for items: [Item]) -> [Segment] {
        segments(
            for: items,
            amount: \.outgo
        )
    }
}

private extension CategoryChartSummaryCalculator {
    static func segments(
        for items: [Item],
        amount: KeyPath<Item, Decimal>
    ) -> [Segment] {
        let groupedItems = Dictionary(grouping: items.filter { item in
            item[keyPath: amount].isNotZero
        }) { item in
            CategoryNameSupport.displayName(
                forStoredName: item.category?.name
            )
        }
        let total = groupedItems.values
            .flatMap(\.self)
            .reduce(.zero) { result, item in
                result + item[keyPath: amount]
            }
        return groupedItems.map { displayName, items in
            let value = items.reduce(.zero) { result, item in
                result + item[keyPath: amount]
            }
            return .init(
                title: displayName,
                value: value,
                ratio: ratio(for: value, total: total)
            )
        }
        .sorted { left, right in
            if left.value != right.value {
                return left.value > right.value
            }
            return left.title < right.title
        }
    }

    static func ratio(for value: Decimal, total: Decimal) -> Double {
        guard total.isNotZero else {
            return .zero
        }
        let totalValue = decimalToDouble(total)
        let currentValue = decimalToDouble(value)
        return currentValue / totalValue
    }

    static func decimalToDouble(_ value: Decimal) -> Double {
        Double(value.description) ?? .zero
    }
}
