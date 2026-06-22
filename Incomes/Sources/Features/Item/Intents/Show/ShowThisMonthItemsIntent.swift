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

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let date = Date.now
        let items = try ItemQueryOperations.items(
            context: modelContainer.mainContext,
            date: date
        )
        return ItemIntentShowResultSupport.itemList(
            items,
            defaultDate: date,
            modelContainer: modelContainer,
            successOpenDate: date
        )
    }
}
