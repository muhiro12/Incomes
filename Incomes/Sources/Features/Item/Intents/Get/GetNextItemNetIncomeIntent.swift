//
//  GetNextItemNetIncomeIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//

import AppIntents
import SwiftData

struct GetNextItemNetIncomeIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Get Next Item Net Income", table: "AppIntents")

    static var parameterSummary: some ParameterSummary {
        Summary {
            \.$date
            \.$ledger
        }
    }

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Parameter(title: "Ledger")
    private var ledger: LedgerEntity?

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ReturnsValue<IntentCurrencyAmount?> {
        let netIncome = try ItemRelativeQueryOperations.netIncome(
            context: modelContainer.mainContext,
            date: date,
            direction: .next,
            ledgerIdentifier: LedgerIntentSupport.identifier(for: ledger, context: modelContainer.mainContext)
        )
        return .result(
            value: ItemIntentCurrencySupport.amount(from: netIncome)
        )
    }
}
