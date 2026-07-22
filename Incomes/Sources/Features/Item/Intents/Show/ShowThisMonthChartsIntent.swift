//
//  ShowThisMonthChartsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//

import AppIntents
import SwiftData

struct ShowThisMonthChartsIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Show This Month's Charts", table: "AppIntents")

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let date = Date.now
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
