//
//  GetPreviousItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

@MainActor
struct GetPreviousItemIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Get Previous Item", table: "AppIntents")

    func perform() throws -> some ReturnsValue<ItemEntity?> {
        guard let item = try ItemService.previousItem(
            context: modelContainer.mainContext,
            date: date
        ) else {
            return .result(value: nil)
        }
        return .result(value: .init(item))
    }
}
