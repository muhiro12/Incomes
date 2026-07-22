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

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let items = try ItemQueryOperations.items(
            context: modelContainer.mainContext,
            date: date
        )
        return ItemIntentShowResultSupport.chartList(
            items,
            defaultDate: date,
            modelContainer: modelContainer
        )
    }
}
