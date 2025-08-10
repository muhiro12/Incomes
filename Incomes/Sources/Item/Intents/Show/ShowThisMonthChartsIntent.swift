//
//  ShowThisMonthChartsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

@MainActor
struct ShowThisMonthChartsIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Show This Month's Charts", table: "AppIntents")

    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let date = Date.now
        let entities = try ItemService.items(
            context: modelContainer.mainContext,
            date: date
        )
        guard entities.isNotEmpty else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        let items = try entities.compactMap { try $0.model(in: modelContainer.mainContext) }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IntentChartSectionGroup(.items(.idsAre(items.map(\.id))))
                .modelContainer(modelContainer)
        }
    }
}
