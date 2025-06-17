//
//  ShowThisMonthItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData
import SwiftUtilities

struct ShowThisMonthItemsIntent: AppIntent, IntentPerformer {
    static let title: LocalizedStringResource = .init("Show This Month's Items", table: "AppIntents")

    @Dependency private var modelContainer: ModelContainer

    typealias Input = (context: ModelContext, date: Date)
    typealias Output = [Item]?

    static func perform(_ input: Input) throws -> Output {
        try ShowItemsIntent.perform(input)
    }

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let date = Date.now
        guard let items = try Self.perform((context: modelContainer.mainContext, date: date)) else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IntentItemListSection(items)
        }
    }
}
