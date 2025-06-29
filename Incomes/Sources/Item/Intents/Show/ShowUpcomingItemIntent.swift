//
//  ShowUpcomingItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData
import SwiftUtilities

struct ShowUpcomingItemIntent: AppIntent, IntentPerformer {
    typealias Input = (container: ModelContainer, date: Date)
    typealias Output = ItemEntity?

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Show Upcoming Item", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        try GetNextItemIntent.perform((container: input.container, date: input.date))
    }

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let date = Date.now
        guard let item = try GetNextItemIntent.perform((container: modelContainer, date: date)) else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: item.content)) {
            IntentItemSection()
                .environment(item)
        }
    }
}
