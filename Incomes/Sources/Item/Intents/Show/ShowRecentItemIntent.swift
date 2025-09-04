//
//  ShowRecentItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

struct ShowRecentItemIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Show Recent Item", table: "AppIntents")

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let date = Date.now
        guard let item = try ItemService.previousItem(
            context: modelContainer.mainContext,
            date: date
        ) else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: item.content)) {
            IntentItemSection()
                .environment(item)
        }
    }
}
