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
struct GetNextItemProfitIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = .init("Get Next Item Profit", table: "AppIntents")

    func perform() throws -> some ReturnsValue<IntentCurrencyAmount?> {
        .result(
            value: try ItemService.nextItemProfit(
                context: modelContainer.mainContext,
                date: date
            )
        )
    }
}
