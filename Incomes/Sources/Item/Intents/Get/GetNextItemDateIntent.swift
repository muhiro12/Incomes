//
//  GetNextItemDateIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

@MainActor
struct GetNextItemDateIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Get Next Item Date", table: "AppIntents")

    func perform() throws -> some ReturnsValue<Date?> {
        .result(
            value: try ItemService.nextItemDate(
                context: modelContainer.mainContext,
                date: date
            )
        )
    }
}
