//
//  ShowItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

struct ShowItemsIntent: AppIntent, @unchecked Sendable {
    static var title = LocalizedStringResource("Show Items")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer
    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IntentsItemListSection(.items(.dateIsSameMonthAs(date)))
                .safeAreaPadding()
                .modelContainer(modelContainer)
        }
    }
}

struct ShowChartsIntent: AppIntent, @unchecked Sendable {
    static var title = LocalizedStringResource("Show Charts")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer
    @Dependency private var itemService: ItemService

    @MainActor
    func perform() throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            ChartSectionGroup(.items(.dateIsSameMonthAs(date)))
                .safeAreaPadding()
                .modelContainer(modelContainer)
        }
    }
}
