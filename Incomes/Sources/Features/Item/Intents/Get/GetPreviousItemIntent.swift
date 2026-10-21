//
//  GetPreviousItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//

import AppIntents
import SwiftData

struct GetPreviousItemIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Get Previous Item", table: "AppIntents")

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
    func perform() throws -> some ReturnsValue<ItemEntity?> {
        let item = try ItemRelativeQueryOperations.item(
            context: modelContainer.mainContext,
            date: date,
            direction: .previous,
            ledgerIdentifier: LedgerIntentSupport.identifier(for: ledger, context: modelContainer.mainContext)
        )
        return .result(
            value: try ItemEntity.make(from: item)
        )
    }
}
