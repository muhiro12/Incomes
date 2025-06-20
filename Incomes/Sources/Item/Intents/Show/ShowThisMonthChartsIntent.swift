//
//  ShowThisMonthChartsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData
import SwiftUtilities

struct ShowThisMonthChartsIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, date: Date)
    typealias Output = [Item]?

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Show This Month's Charts", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        try ShowChartsIntent.perform(input)
    }

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let date = Date.now
        guard let items = try Self.perform((context: modelContainer.mainContext, date: date)) else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IntentChartSectionGroup(.items(.idsAre(items.map(\.id))))
                .modelContainer(modelContainer)
        }
    }
}
