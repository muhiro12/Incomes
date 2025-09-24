//
//  SummaryCalculator.swift
//  IncomesLibrary
//
//  Aggregates item values for reporting without UI concerns.
//

import Foundation
import SwiftData

public enum SummaryCalculator {
    public struct MonthlyTotals: Sendable {
        public let totalIncome: Decimal
        public let totalOutgo: Decimal
        public let netIncome: Decimal

        public init(totalIncome: Decimal, totalOutgo: Decimal) {
            self.totalIncome = totalIncome
            self.totalOutgo = totalOutgo
            self.netIncome = totalIncome - totalOutgo
        }
    }

    /// Returns totals for the month that contains `date`.
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
