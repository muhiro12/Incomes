//
//  ShowPreviousItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData
import SwiftUtilities

struct ShowPreviousItemIntent: AppIntent, IntentPerformer {
    typealias Input = (container: ModelContainer, date: Date)
    typealias Output = ItemEntity?

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Show Previous Item", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        try GetPreviousItemIntent.perform(input)
    }

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        guard let item = try Self.perform((container: modelContainer, date: date)) else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: item.content)) {
            IntentItemSection()
                .environment(item)
        }
    }
}
