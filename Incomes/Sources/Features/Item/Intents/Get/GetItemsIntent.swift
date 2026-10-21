//
//  GetItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//

import AppIntents
import SwiftData

struct GetItemsIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Get Items", table: "AppIntents")

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
    func perform() throws -> some ReturnsValue<[ItemEntity]> {
        let items = try ItemQueryOperations.items(
            context: modelContainer.mainContext,
            date: date,
            ledgerIdentifier: LedgerIntentSupport.identifier(for: ledger, context: modelContainer.mainContext)
        )
        return .result(
            value: try ItemEntity.make(from: items)
        )
    }
}
