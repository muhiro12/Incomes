//
//  ShowPreviousItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//

import AppIntents
import SwiftData

struct ShowPreviousItemsIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date // swiftlint:disable:this type_contents_order

    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Show Previous Items", table: "AppIntents")

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
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
