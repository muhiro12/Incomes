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
struct GetPreviousItemDateIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, date: Date)
    typealias Output = Date?

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Get Previous Item Date", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        return try ItemService.previousItemDate(
            context: input.context,
            date: input.date
        )
    }

    func perform() throws -> some ReturnsValue<Date?> {
        return .result(
            value: try Self.perform(
                (context: modelContainer.mainContext, date: date)
            )
        )
    }
}
