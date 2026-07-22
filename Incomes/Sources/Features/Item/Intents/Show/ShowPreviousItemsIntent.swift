//
//  ShowPreviousItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//

import AppIntents
import SwiftData

struct ShowPreviousItemsIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Show Previous Items", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let items = try ItemRelativeQueryOperations.items(
            context: modelContainer.mainContext,
            date: date,
            direction: .previous
        )
        return ItemIntentShowResultSupport.itemList(
            items,
            defaultDate: date,
            modelContainer: modelContainer
        )
    }
}
