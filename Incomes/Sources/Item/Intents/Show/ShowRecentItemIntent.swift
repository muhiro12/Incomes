//
//  ShowRecentItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//

import AppIntents
import SwiftData

struct ShowRecentItemIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Show Recent Item", table: "AppIntents")

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let date = Date.now
        let defaultOpenIntent = IncomesIntentRouteOpener.monthIntent(for: date)
        guard let item = try ItemService.previousItem(
            context: modelContainer.mainContext,
            date: date
        ) else {
            return .result(
                opensIntent: defaultOpenIntent,
                dialog: .init(.init("Not Found", table: "AppIntents"))
            )
        }
        return .result(
            opensIntent: IncomesIntentRouteOpener.monthIntent(for: item.localDate),
            dialog: .init(stringLiteral: item.content)
        ) {
            IntentItemSection()
                .environment(item)
        }
    }
}
