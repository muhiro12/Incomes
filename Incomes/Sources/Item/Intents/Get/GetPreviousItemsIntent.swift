//
//  GetPreviousItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/26.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

struct GetPreviousItemsIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Get Previous Items", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<[ItemEntity]> {
        .result(
            value: try ItemService.previousItems(
                context: modelContainer.mainContext,
                date: date
            ).compactMap(ItemEntity.init)
        )
    }
}
