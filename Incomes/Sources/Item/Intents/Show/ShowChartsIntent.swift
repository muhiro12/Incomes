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
    typealias Output = [ItemEntity]

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Show Charts", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        let items = try input.context.fetch(
            .items(.dateIsSameMonthAs(input.date))
        )
        return items.compactMap(ItemEntity.init)
    }

    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        let entities = try Self.perform(
            (context: modelContainer.mainContext, date: date)
        )
        guard entities.isNotEmpty else {
            return .result(dialog: .init(.init("Not Found", table: "AppIntents")))
        }
        let items = try entities.compactMap { try $0.model(in: modelContainer.mainContext) }
        return .result(dialog: .init(stringLiteral: date.stringValue(.yyyyMMM))) {
            IntentChartSectionGroup(.items(.idsAre(items.map(\.id))))
                .modelContainer(modelContainer)
        }
    }
}
