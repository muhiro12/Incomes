//
//  ShowItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData
import SwiftUtilities

struct ShowItemsIntent: AppIntent, IntentPerformer {
    typealias Input = (container: ModelContainer, date: Date)
    typealias Output = [ItemEntity]

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Show Items", table: "AppIntents")

    @MainActor
    static func perform(_ input: Input) throws -> Output {
        let items = try input.container.mainContext.fetch(
            .items(.dateIsSameMonthAs(input.date))
        )
        return items.compactMap(ItemEntity.init)
    }

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let items = try Self.perform(
            (container: modelContainer, date: date)
        )
        guard items.isNotEmpty else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IntentItemListSection(items)
        }
    }
}
