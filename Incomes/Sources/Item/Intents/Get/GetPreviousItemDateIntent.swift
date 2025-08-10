//
//  GetPreviousItemDateIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

@MainActor
struct GetPreviousItemDateIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Get Previous Item Date", table: "AppIntents")

    func perform() throws -> some ReturnsValue<Date?> {
        return .result(
            value: try ItemService.previousItemDate(
                context: modelContainer.mainContext,
                date: date
            )
        )
    }
}
