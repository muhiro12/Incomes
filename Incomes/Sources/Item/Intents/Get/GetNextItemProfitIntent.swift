//
//  GetNextItemProfitIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData
import SwiftUI

@MainActor
struct GetNextItemProfitIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, date: Date)
    typealias Output = IntentCurrencyAmount?

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Get Next Item Profit", table: "AppIntents")

    static func perform(_ input: Input) throws -> Output {
        return try ItemService.nextItemProfit(
            context: input.context,
            date: input.date
        )
    }

    func perform() throws -> some ReturnsValue<IntentCurrencyAmount?> {
        return .result(
            value: try Self.perform(
                (context: modelContainer.mainContext, date: date)
            )
        )
    }
}
