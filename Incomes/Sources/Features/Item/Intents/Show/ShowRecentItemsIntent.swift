//
//  ShowRecentItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//

import AppIntents
import SwiftData

struct ShowRecentItemsIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Show Recent Items", table: "AppIntents")

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let date = Date.now
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
