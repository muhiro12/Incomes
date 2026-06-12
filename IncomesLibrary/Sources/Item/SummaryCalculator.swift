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

        let income: Decimal = items.reduce(.zero) { partial, item in
            partial + item.income
        }
        let outgo: Decimal = items.reduce(.zero) { partial, item in
            partial + item.outgo
        }

        return .init(totalIncome: income, totalOutgo: outgo)
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

        let currentTotals = categoryTotals(for: currentItems)
        let previousTotals = categoryTotals(for: previousItems)
        let categories = Set(currentTotals.keys).union(previousTotals.keys)

        return categories.compactMap { category in
            let currentTotal = currentTotals[category] ?? .init()
            let previousTotal = previousTotals[category] ?? .init()
            let comparison = CategoryComparison(
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
    static func totalIncome(for items: [Item]) -> Decimal {
        items.reduce(.zero) { result, item in
            result + item.income
        }
    }

    /// Returns total outgo for the provided items.
    static func totalOutgo(for items: [Item]) -> Decimal {
        items.reduce(.zero) { result, item in
            result + item.outgo
        }
    }
}

private extension SummaryCalculator {
    struct CategoryTotals {
        var income: Decimal = .zero
        var outgo: Decimal = .zero
    }

    static func categoryTotals(for items: [Item]) -> [String: CategoryTotals] {
        items.reduce(into: [String: CategoryTotals]()) { result, item in
            let category = CategoryNameSupport.displayName(
                forStoredName: item.category?.name
            )
            var totals = result[category] ?? .init()
            totals.income += item.income
            totals.outgo += item.outgo
            result[category] = totals
        }
    }

    static func hasAnyValue(_ comparison: CategoryComparison) -> Bool {
        comparison.currentIncome.isNotZero ||
            comparison.previousIncome.isNotZero ||
            comparison.currentOutgo.isNotZero ||
            comparison.previousOutgo.isNotZero
    }

    static func maximumAbsoluteDelta(for comparison: CategoryComparison) -> Decimal {
        let incomeMagnitude = absoluteValue(comparison.incomeDelta)
        let outgoMagnitude = absoluteValue(comparison.outgoDelta)
        return max(incomeMagnitude, outgoMagnitude)
    }

    static func absoluteValue(_ value: Decimal) -> Decimal {
        value.isMinus ? value * -1 : value
    }
}
