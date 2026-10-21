//
//  ShowThisMonthItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//

import AppIntents
import SwiftData

struct ShowThisMonthItemsIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Show This Month's Items", table: "AppIntents")

    static var parameterSummary: some ParameterSummary {
        Summary {
            \.$ledger
        }
    }

    @Parameter(title: "Ledger")
    private var ledger: LedgerEntity?

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let identifier = try LedgerIntentSupport.identifier(for: ledger, context: modelContainer.mainContext)
        let date = Date.now
        let items = try ItemQueryOperations.items(
            context: modelContainer.mainContext,
            date: date,
            ledgerIdentifier: identifier
        )
        return ItemIntentShowResultSupport.itemList(
            items,
            defaultDate: date,
            modelContainer: modelContainer,
            successOpenDate: date,
            ledgerIdentifier: identifier
        )
    }
}
