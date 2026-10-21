//
//  GetPreviousItemDateIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//

import AppIntents
import SwiftData

struct GetPreviousItemDateIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Get Previous Item Date", table: "AppIntents")

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
    func perform() throws -> some ReturnsValue<Date?> {
        .result(
            value: try ItemRelativeQueryOperations.localDate(
                context: modelContainer.mainContext,
                date: date,
                direction: .previous,
                ledgerIdentifier: LedgerIntentSupport.identifier(for: ledger, context: modelContainer.mainContext)
            )
        )
    }
}
