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
}
