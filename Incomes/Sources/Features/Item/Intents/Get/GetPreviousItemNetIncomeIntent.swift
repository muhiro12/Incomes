//
//  GetPreviousItemNetIncomeIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//

import AppIntents
import SwiftData

struct GetPreviousItemNetIncomeIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Get Previous Item Net Income", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ReturnsValue<IntentCurrencyAmount?> {
        let netIncome = try ItemRelativeQueryOperations.netIncome(
            context: modelContainer.mainContext,
            date: date,
            direction: .previous
        )
        return .result(
            value: ItemIntentCurrencySupport.amount(from: netIncome)
        )
    }
}
