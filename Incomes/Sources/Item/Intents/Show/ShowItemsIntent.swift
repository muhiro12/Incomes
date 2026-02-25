//
//  ShowItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

struct ShowItemsIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Show Items", table: "AppIntents")

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let items = try ItemService.items(
            context: modelContainer.mainContext,
            date: date
        )
        let openIntent = IncomesIntentRouteOpener.monthIntent(for: date)
        guard items.isNotEmpty else {
            return .result(
                opensIntent: openIntent,
                dialog: .init(.init("Not Found", table: "AppIntents"))
            )
        }
        return .result(
            opensIntent: openIntent,
            dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))
        ) {
            IntentItemListSection(items)
                .modelContainer(modelContainer)
        }
    }
}
