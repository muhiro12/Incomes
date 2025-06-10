//
//  ShowThisMonthChartsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

struct ShowThisMonthChartsIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Show This Month's Charts", table: "AppIntents")

    @Dependency private var itemService: ItemService
    @Dependency private var modelContainer: ModelContainer

    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let date = Date.now
        guard let items = try ShowChartsIntent.perform(date: date, itemService: itemService) else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IntentChartSectionGroup(.items(.idsAre(items.map(\.id))))
                .modelContainer(modelContainer)
        }
    }
}
