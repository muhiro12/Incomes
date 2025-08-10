//
//  GetItemsIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

@MainActor
struct GetItemsIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Get Items", table: "AppIntents")

    func perform() throws -> some ReturnsValue<[ItemEntity]> {
        let items = try ItemService.items(
            context: modelContainer.mainContext,
            date: date
        )
        return .result(value: items)
    }
}
