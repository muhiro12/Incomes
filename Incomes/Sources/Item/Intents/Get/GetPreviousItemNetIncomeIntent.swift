//
//  GetPreviousItemNetIncomeIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData
import SwiftUI

struct GetPreviousItemNetIncomeIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Get Previous Item Net Income", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<IntentCurrencyAmount?> {
        let netIncome = try ItemService.previousItem(
            context: modelContainer.mainContext,
            date: date
        )?.netIncome
        guard let netIncome else {
            return .result(value: nil)
        }
        let currencyCode = AppStorage(.currencyCode).wrappedValue
        return .result(value: .init(amount: netIncome, currencyCode: currencyCode))
    }
}
