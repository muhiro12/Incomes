//
//  GetPreviousItemProfitIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftUI

struct GetPreviousItemProfitIntent: AppIntent, IntentPerformer, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Get Previous Item Profit", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date

    @Dependency private var itemService: ItemService

    typealias Input = (date: Date, itemService: ItemService)
    typealias Output = IntentCurrencyAmount?

    static func perform(_ input: Input) throws -> Output {
        guard let item = try GetPreviousItemIntent.perform(input) else {
            return nil
        }
        let currencyCode = AppStorage(.currencyCode).wrappedValue
        return .init(amount: item.profit, currencyCode: currencyCode)
    }

    func perform() throws -> some ReturnsValue<IntentCurrencyAmount?> {
        guard let amount = try Self.perform((date: date, itemService: itemService)) else {
            return .result(value: nil)
        }
        return .result(value: amount)
    }
}
