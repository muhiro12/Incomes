//
//  GetPreviousItemContentIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

struct GetPreviousItemContentIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Get Previous Item Content", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<String?> {
        .result(
            value: try ItemService.previousItemContent(
                context: modelContainer.mainContext,
                date: date
            )
        )
    }
}
