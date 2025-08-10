//
//  GetNextItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/26.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

@MainActor
struct GetNextItemsIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, date: Date)
    typealias Output = [ItemEntity]

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Get Next Items", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        return try ItemService.nextItems(
            context: input.context,
            date: input.date
        )
    }

    func perform() throws -> some ReturnsValue<[ItemEntity]> {
        let items = try Self.perform(
            (context: modelContainer.mainContext, date: date)
        )
        return .result(value: items)
    }
}
