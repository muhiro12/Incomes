//
//  ShowRecentItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//

import AppIntents
import SwiftData

struct ShowRecentItemsIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Show Recent Items", table: "AppIntents")

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let date = Date.now
        let items = try ItemService.previousItems(
            context: modelContainer.mainContext,
            date: date
        )
        let defaultOpenIntent = IncomesIntentRouteOpener.monthIntent(for: date)
        guard items.isNotEmpty else {
            return .result(
                opensIntent: defaultOpenIntent,
                dialog: .init(.init("Not Found", table: "AppIntents"))
            )
        }
        return .result(
            opensIntent: IncomesIntentRouteOpener.monthIntent(for: items[0].localDate),
            dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))
        ) {
            IntentItemListSection(items)
                .modelContainer(modelContainer)
        }
    }
}
