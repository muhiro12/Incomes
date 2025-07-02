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
import SwiftUtilities

struct GetNextItemProfitIntent: AppIntent, IntentPerformer {
    typealias Input = (container: ModelContainer, date: Date)
    typealias Output = IntentCurrencyAmount?

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = .init("Get Next Item Profit", table: "AppIntents")

    @MainActor
    static func perform(_ input: Input) throws -> Output {
        guard let item = try GetNextItemIntent.perform((container: input.container, date: input.date)) else {
            return nil
        }
        let currencyCode = AppStorage(.currencyCode).wrappedValue
        return .init(amount: item.profit, currencyCode: currencyCode)
    }

    @MainActor
    func perform() throws -> some ReturnsValue<IntentCurrencyAmount?> {
        guard let item = try GetNextItemIntent.perform((container: modelContainer, date: date)) else {
            return .result(value: nil)
        }
        let currencyCode = AppStorage(.currencyCode).wrappedValue
        return .result(value: .init(amount: item.profit, currencyCode: currencyCode))
    }
}
