//
//  ShowChartsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//

import AppIntents
import SwiftData

struct ShowChartsIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date // swiftlint:disable:this type_contents_order

    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Show Charts", table: "AppIntents")

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
            IntentChartSectionGroup(.items(.idsAre(items.map(\.id))))
                .modelContainer(modelContainer)
        }
    }
}
