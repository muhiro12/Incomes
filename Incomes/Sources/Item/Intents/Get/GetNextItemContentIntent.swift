//
//  GetNextItemContentIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

@MainActor
struct GetNextItemContentIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Get Next Item Content", table: "AppIntents")

    func perform() throws -> some ReturnsValue<String?> {
        .result(
            value: try ItemService.nextItemContent(
                context: modelContainer.mainContext,
                date: date
            )
        )
    }
}
