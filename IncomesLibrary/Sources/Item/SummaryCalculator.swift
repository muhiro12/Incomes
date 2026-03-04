//
//  SummaryCalculator.swift
//  IncomesLibrary
//
//  Aggregates item values for reporting without UI concerns.
//

import Foundation
import SwiftData

/// Utilities for aggregating financial summaries without any UI concerns.
public enum SummaryCalculator {
    /// A value type that represents monthly totals.
    public struct MonthlyTotals: Sendable {
        /// Sum of all item incomes within the target month.
        public let totalIncome: Decimal
        /// Sum of all item outgo amounts within the target month.
        public let totalOutgo: Decimal
        /// Convenience value: `totalIncome - totalOutgo`.
        public let netIncome: Decimal

        /// Creates a new `MonthlyTotals` value.
        /// - Parameters:
        ///   - totalIncome: Sum of incomes.
        ///   - totalOutgo: Sum of outgo amounts.
        public init(totalIncome: Decimal, totalOutgo: Decimal) {
            self.totalIncome = totalIncome
            self.totalOutgo = totalOutgo
            self.netIncome = totalIncome - totalOutgo
        }
    }

    /// A value type that compares category totals between the current and previous month.
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
        /// - Parameters:
        ///   - category: Display category name.
        ///   - currentIncome: Current-month income total.
        ///   - previousIncome: Previous-month income total.
        ///   - currentOutgo: Current-month outgo total.
        ///   - previousOutgo: Previous-month outgo total.
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
            self.incomeDelta = currentIncome - previousIncome
            self.currentOutgo = currentOutgo
            self.previousOutgo = previousOutgo
            self.outgoDelta = currentOutgo - previousOutgo
        }
    }

    /// Calculates totals for the month that contains `date`.
    /// - Parameters:
    ///   - context: A `ModelContext` to query items from.
    ///   - date: Any date inside the target month.
    /// - Returns: The aggregated monthly totals.
    public static func monthlyTotals(context: ModelContext, date: Date) throws -> MonthlyTotals {
        let items = try ItemService.items(context: context, date: date)

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
    public static func categoryComparison(
        context: ModelContext,
        date: Date
    ) throws -> [CategoryComparison] {
        let currentItems = try ItemService.items(context: context, date: date)
        let previousMonthDate = Calendar.utc.date(byAdding: .month, value: -1, to: date) ?? date
        let previousItems = try ItemService.items(context: context, date: previousMonthDate)

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
}

private extension SummaryCalculator {
    struct CategoryTotals {
        var income: Decimal = .zero
        var outgo: Decimal = .zero
    }

    static func categoryTotals(for items: [Item]) -> [String: CategoryTotals] {
        items.reduce(into: [String: CategoryTotals]()) { result, item in
            let category = item.category?.displayName ?? "Others"
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
