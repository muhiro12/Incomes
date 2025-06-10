//
//  ShowChartsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

struct ShowChartsIntent: AppIntent, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Show Charts", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService
    @Dependency private var modelContainer: ModelContainer

    static func perform(date: Date,
                        itemService: ItemService) throws -> [Item]? {
        let items = try itemService.items(.items(.dateIsSameMonthAs(date)))
        return items.isEmpty ? nil : items
    }

    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        guard let items = try Self.perform(date: date, itemService: itemService) else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IntentChartSectionGroup(.items(.idsAre(items.map(\.id))))
                .modelContainer(modelContainer)
        }
    }
}
