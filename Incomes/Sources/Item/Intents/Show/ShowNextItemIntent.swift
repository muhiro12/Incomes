//
//  ShowNextItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData
import SwiftUtilities

struct ShowNextItemIntent: AppIntent, IntentPerformer {
    typealias Input = (container: ModelContainer, date: Date)
    typealias Output = ItemEntity?

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Show Next Item", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        try GetNextItemIntent.perform((container: input.container, date: input.date))
    }

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        guard let item = try GetNextItemIntent.perform((container: modelContainer, date: date)) else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: item.content)) {
            IntentItemSection()
                .environment(item)
        }
    }
}
