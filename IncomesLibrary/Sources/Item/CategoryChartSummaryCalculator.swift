//
//  CategoryChartSummaryCalculator.swift
//  IncomesLibrary
//
//  Builds category summaries for chart-based item reporting.
//

import Foundation

/// Utilities for building category chart summaries without app UI dependencies.
enum CategoryChartSummaryCalculator {
    typealias Segment = ItemSummaryOperations.ChartSegment

    /// Returns income chart segments grouped by category.
    static func incomeSegments(for items: [Item]) throws -> [Segment] {
        try segments(
            for: items,
            amount: \.income
        )
    }

    /// Returns outgo chart segments grouped by category.
    static func outgoSegments(for items: [Item]) throws -> [Segment] {
        try segments(
            for: items,
            amount: \.outgo
        )
    }
}

private extension CategoryChartSummaryCalculator {
    static func segments(
        for items: [Item],
        amount: KeyPath<Item, Decimal>
    ) throws -> [Segment] {
        let groupedItems = Dictionary(grouping: items.filter { item in
            item[keyPath: amount] != .zero
        }) { item in
            CategoryNameSupport.displayName(
                forStoredName: item.category?.name
            )
        }
        let total = try ExactAmountArithmetic.checkedTotal(
            groupedItems.values.flatMap(\.self).map { item in
                item[keyPath: amount]
            }
        )
        return try groupedItems.map { displayName, items in
            let value = try ExactAmountArithmetic.checkedTotal(
                items.map { item in
                    item[keyPath: amount]
                }
            )
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
        guard total != .zero else {
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
