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
struct GetNextItemsIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Get Next Items", table: "AppIntents")

    func perform() throws -> some ReturnsValue<[ItemEntity]> {
        .result(
            value: try ItemService.nextItems(
                context: modelContainer.mainContext,
                date: date
            ).compactMap(ItemEntity.init)
        )
    }
}
