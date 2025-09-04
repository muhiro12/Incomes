//
//  GetPreviousItemProfitIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData
import SwiftUI

struct GetPreviousItemProfitIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Get Previous Item Profit", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<IntentCurrencyAmount?> {
        let profit = try ItemService.previousItem(
            context: modelContainer.mainContext,
            date: date
        )?.profit
        guard let profit else {
            return .result(value: nil)
        }
        let currencyCode = AppStorage(.currencyCode).wrappedValue
        return .result(value: .init(amount: profit, currencyCode: currencyCode))
    }
}
