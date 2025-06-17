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
import SwiftUtilities

struct GetPreviousItemProfitIntent: AppIntent, IntentPerformer {
    static let title: LocalizedStringResource = .init("Get Previous Item Profit", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    typealias Input = (context: ModelContext, date: Date)
    typealias Output = IntentCurrencyAmount?

    static func perform(_ input: Input) throws -> Output {
        guard let item = try GetPreviousItemIntent.perform(input) else {
            return nil
        }
        let currencyCode = AppStorage(.currencyCode).wrappedValue
        return .init(amount: item.profit, currencyCode: currencyCode)
    }

    @MainActor
    func perform() throws -> some ReturnsValue<IntentCurrencyAmount?> {
        guard let amount = try Self.perform((context: modelContainer.mainContext, date: date)) else {
            return .result(value: nil)
        }
        return .result(value: amount)
    }
}
