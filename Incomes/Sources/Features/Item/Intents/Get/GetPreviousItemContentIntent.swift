//
//  GetPreviousItemContentIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//

import AppIntents
import SwiftData

struct GetPreviousItemContentIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Get Previous Item Content", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ReturnsValue<String?> {
        .result(
            value: try ItemRelativeQueryOperations.content(
                context: modelContainer.mainContext,
                date: date,
                direction: .previous
            )
        )
    }
}
