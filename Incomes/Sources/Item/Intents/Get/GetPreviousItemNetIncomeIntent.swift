//
//  GetPreviousItemNetIncomeIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//

import AppIntents
import SwiftData

struct GetPreviousItemNetIncomeIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date // swiftlint:disable:this type_contents_order

    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Get Previous Item Net Income", table: "AppIntents")

    @MainActor
    func perform() throws -> some ReturnsValue<IntentCurrencyAmount?> {
        let item = try ItemQueryOperations.previousItem(
            context: modelContainer.mainContext,
            date: date
        )
        return .result(
            value: ItemIntentCurrencySupport.amount(from: item?.netIncome)
        )
    }
}
