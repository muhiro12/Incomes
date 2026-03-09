//
//  GetCategoryComparisonTool.swift
//  Incomes
//
//  Created by Codex on 2026/03/05.
//

import Foundation
import FoundationModels
import SwiftData

@available(iOS 26.0, *)
struct GetCategoryComparisonTool: Tool {
    let modelContainer: ModelContainer

    var name: String {
        "getCategoryComparison"
    }

    var description: String {
        "Returns the biggest category-level income and outgo changes between the requested month and the previous month." // swiftlint:disable:this line_length
    }

    func call(arguments: YearMonthArguments) throws -> CategoryComparisonSnapshot {
        let context = ModelContext(modelContainer)
        let date = try arguments.resolvedDate()
        let comparisons = try SummaryCalculator.categoryComparison(context: context, date: date)
        let previousMonthDate = Calendar.utc.date(byAdding: .month, value: -1, to: date) ?? date
        let previousComponents = Calendar.utc.dateComponents([.year, .month], from: previousMonthDate)

        return .init(
            year: arguments.year,
            month: arguments.month,
            previousYear: previousComponents.year ?? arguments.year,
            previousMonth: previousComponents.month ?? arguments.month,
            comparisons: comparisons.prefix(8).map { comparison in // swiftlint:disable:this no_magic_numbers
                .init(
                    category: comparison.category,
                    currentIncome: comparison.currentIncome,
                    previousIncome: comparison.previousIncome,
                    incomeDelta: comparison.incomeDelta,
                    currentOutgo: comparison.currentOutgo,
                    previousOutgo: comparison.previousOutgo,
                    outgoDelta: comparison.outgoDelta
                )
            }
        )
    }
}
