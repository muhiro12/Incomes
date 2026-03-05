//
//  GetMonthlyTotalsTool.swift
//  Incomes
//
//  Created by Codex on 2026/03/05.
//

import Foundation
import FoundationModels
import SwiftData

@available(iOS 26.0, *)
struct GetMonthlyTotalsTool: Tool {
    let modelContainer: ModelContainer
    let currencyCode: String

    var name: String {
        "getMonthlyTotals"
    }

    var description: String {
        "Returns total income, total outgo, and net income for a requested month."
    }

    func call(arguments: YearMonthArguments) throws -> MonthlyTotalsSnapshot {
        let context = ModelContext(modelContainer)
        let date = try arguments.resolvedDate()
        let totals = try SummaryCalculator.monthlyTotals(context: context, date: date)

        return .init(
            year: arguments.year,
            month: arguments.month,
            currencyCode: currencyCode,
            totalIncome: totals.totalIncome,
            totalOutgo: totals.totalOutgo,
            netIncome: totals.netIncome
        )
    }
}
