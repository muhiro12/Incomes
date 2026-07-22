//
//  GetNextItemDateIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//

import AppIntents
import SwiftData

struct GetNextItemDateIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Get Next Item Date", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ReturnsValue<Date?> {
        .result(
            value: try ItemRelativeQueryOperations.localDate(
                context: modelContainer.mainContext,
                date: date,
                direction: .next
            )
        )
    }
}
