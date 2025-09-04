//
//  GetNextItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

struct GetNextItemIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Get Next Item", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<ItemEntity?> {
        guard let item = try ItemService.nextItem(
            context: modelContainer.mainContext,
            date: date
        ) else {
            return .result(value: nil)
        }
        return .result(value: .init(item))
    }
}
