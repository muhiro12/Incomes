//
//  SummaryCalculator.swift
//  IncomesLibrary
//
//  Aggregates item values for reporting without UI concerns.
//

import Foundation
import SwiftData

/// Utilities for aggregating financial summaries without any UI concerns.
enum SummaryCalculator {
    typealias MonthlyTotals = ItemSummaryOperations.MonthlyTotals
    typealias CategoryComparison = ItemSummaryOperations.CategoryComparison

    /// Calculates totals for the month that contains `date`.
    /// - Parameters:
    ///   - context: A `ModelContext` to query items from.
    ///   - date: Any date inside the target month.
    /// - Returns: The aggregated monthly totals.
    static func monthlyTotals(context: ModelContext, date: Date) throws -> MonthlyTotals {
        let items = try ItemQueryOperations.items(context: context, date: date)

        return try monthlyTotals(for: items)
    }

    /// Calculates totals for the provided items.
    /// - Throws: `ItemAmountError.totalOutOfRange` when a total is not exact.
    static func monthlyTotals(for items: [Item]) throws -> MonthlyTotals {
        try .init(
            totalIncome: totalIncome(for: items),
            totalOutgo: totalOutgo(for: items)
        )
    }

    /// Compares category totals for the month containing `date` with the previous month.
    /// - Parameters:
    ///   - context: A `ModelContext` to query items from.
    ///   - date: Any date inside the target month.
    /// - Returns: Deterministically sorted category comparisons.
    static func categoryComparison(
        context: ModelContext,
        date: Date
    ) throws -> [CategoryComparison] {
        let currentItems = try ItemQueryOperations.items(context: context, date: date)
        let previousMonthDate = MonthlySummaryDateSupport.previousMonthDate(from: date)
        let previousItems = try ItemQueryOperations.items(context: context, date: previousMonthDate)

        return try categoryComparison(
            currentItems: currentItems,
            previousItems: previousItems
        )
    }

    /// Compares category totals for provided current and previous month items.
    /// - Throws: `ItemAmountError.totalOutOfRange` when a total or delta is not exact.
    static func categoryComparison(
        currentItems: [Item],
        previousItems: [Item]
    ) throws -> [CategoryComparison] {
        let currentTotals = try categoryTotals(for: currentItems)
        let previousTotals = try categoryTotals(for: previousItems)
        let categories = Set(currentTotals.keys).union(previousTotals.keys)

        return try categories.compactMap { category in
            let currentTotal = currentTotals[category] ?? .init()
            let previousTotal = previousTotals[category] ?? .init()
            let comparison = try CategoryComparison(
                category: category,
                currentIncome: currentTotal.income,
                previousIncome: previousTotal.income,
                currentOutgo: currentTotal.outgo,
                previousOutgo: previousTotal.outgo
            )
            guard hasAnyValue(comparison) else {
                return nil
            }
            return comparison
        }
        .sorted { left, right in
            let leftMagnitude = maximumAbsoluteDelta(for: left)
            let rightMagnitude = maximumAbsoluteDelta(for: right)
            if leftMagnitude != rightMagnitude {
                return leftMagnitude > rightMagnitude
            }
            return left.category < right.category
        }
    }

    /// Returns total income for the provided items.
    /// - Throws: `ItemAmountError.totalOutOfRange` when the total is not exact.
    static func totalIncome(for items: [Item]) throws -> Decimal {
        try ExactAmountArithmetic.checkedTotal(items.map(\.income))
    }

    /// Returns total outgo for the provided items.
    /// - Throws: `ItemAmountError.totalOutOfRange` when the total is not exact.
    static func totalOutgo(for items: [Item]) throws -> Decimal {
        try ExactAmountArithmetic.checkedTotal(items.map(\.outgo))
    }
}

private extension SummaryCalculator {
    struct CategoryTotals {
        var income: Decimal = .zero
        var outgo: Decimal = .zero
    }

    static func categoryTotals(for items: [Item]) throws -> [String: CategoryTotals] {
        try items.reduce(into: [String: CategoryTotals]()) { result, item in
            let category = CategoryNameSupport.displayName(
                forStoredName: item.category?.name
            )
            let totals = result[category] ?? .init()
            result[category] = .init(
                income: try ExactAmountArithmetic.checkedTotal([totals.income, item.income]),
                outgo: try ExactAmountArithmetic.checkedTotal([totals.outgo, item.outgo])
            )
        }
    }

    static func hasAnyValue(_ comparison: CategoryComparison) -> Bool {
        comparison.currentIncome != .zero ||
            comparison.previousIncome != .zero ||
            comparison.currentOutgo != .zero ||
            comparison.previousOutgo != .zero
    }

    static func maximumAbsoluteDelta(for comparison: CategoryComparison) -> Decimal {
        let incomeMagnitude = absoluteValue(comparison.incomeDelta)
        let outgoMagnitude = absoluteValue(comparison.outgoDelta)
        return max(incomeMagnitude, outgoMagnitude)
    }

    static func absoluteValue(_ value: Decimal) -> Decimal {
        value < .zero ? value * -1 : value
    }
}
