//
//  ShowUpcomingItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

struct ShowUpcomingItemsIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Show Upcoming Items", table: "AppIntents")

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let date = Date.now
        let items = try ItemService.nextItems(
            context: modelContainer.mainContext,
            date: date
        )
        guard items.isNotEmpty else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IntentItemListSection(items)
                .modelContainer(modelContainer)
        }
    }
}
