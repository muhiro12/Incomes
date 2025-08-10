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
struct GetNextItemContentIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, date: Date)
    typealias Output = String?

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Get Next Item Content", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        return try ItemService.nextItemContent(
            context: input.context,
            date: input.date
        )
    }

    func perform() throws -> some ReturnsValue<String?> {
        return .result(
            value: try Self.perform(
                (context: modelContainer.mainContext, date: date)
            )
        )
    }
}
