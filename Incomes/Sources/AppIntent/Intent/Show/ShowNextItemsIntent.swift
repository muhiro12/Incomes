//
//  ShowNextItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftUtilities

struct ShowNextItemsIntent: AppIntent, IntentPerformer {
    static let title: LocalizedStringResource = .init("Show Next Items", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    typealias Input = (context: ModelContext, date: Date)
    typealias Output = [Item]?

    static func perform(_ input: Input) throws -> Output {
        try GetNextItemsIntent.perform(input)
    }

    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        guard let items = try Self.perform((context: modelContainer.mainContext, date: date)),
              items.isNotEmpty else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IntentItemListSection(items)
        }
    }
}
