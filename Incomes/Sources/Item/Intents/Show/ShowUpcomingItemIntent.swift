//
//  ShowUpcomingItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

@MainActor
struct ShowUpcomingItemIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, date: Date)
    typealias Output = ItemEntity?

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Show Upcoming Item", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        return try ItemService.nextItem(
            context: input.context,
            date: input.date
        )
    }

    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let date = Date.now
        guard let item = try Self.perform(
            (context: modelContainer.mainContext, date: date)
        ) else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: item.content)) {
            IntentItemSection()
                .environment(try! item.model(in: modelContainer.mainContext))
        }
    }
}
