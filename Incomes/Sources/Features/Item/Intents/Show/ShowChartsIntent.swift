//
//  ShowChartsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//

import AppIntents
import SwiftData

struct ShowChartsIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Show Charts", table: "AppIntents")

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
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let identifier = try LedgerIntentSupport.identifier(for: ledger, context: modelContainer.mainContext)
        let items = try ItemQueryOperations.items(
            context: modelContainer.mainContext,
            date: date,
            ledgerIdentifier: identifier
        )
        return ItemIntentShowResultSupport.chartList(
            items,
            defaultDate: date,
            modelContainer: modelContainer,
            ledgerIdentifier: identifier
        )
    }
}
