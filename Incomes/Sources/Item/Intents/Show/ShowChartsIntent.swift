//
//  ShowChartsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData
import SwiftUtilities

struct ShowChartsIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, date: Date)
    typealias Output = [Item]?

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Show Charts", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        let items = try input.context.fetch(
            .items(.dateIsSameMonthAs(input.date))
        )
        return items.isEmpty ? nil : items
    }

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        guard let items = try Self.perform((context: modelContainer.mainContext, date: date)) else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IntentChartSectionGroup(.items(.idsAre(items.map(\.id))))
                .modelContainer(modelContainer)
        }
    }
}
