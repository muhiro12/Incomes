//
//  GetPreviousItemContentIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

@MainActor
struct GetPreviousItemContentIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Get Previous Item Content", table: "AppIntents")

    func perform() throws -> some ReturnsValue<String?> {
        return .result(
            value: try ItemService.previousItemContent(
                context: modelContainer.mainContext,
                date: date
            )
        )
    }
}
