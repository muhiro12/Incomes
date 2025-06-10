//
//  CreateItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftUI

struct CreateItemIntent: AppIntent, IntentPerformer, @unchecked Sendable {
    static let title: LocalizedStringResource = .init("Create Item", table: "AppIntents")

    @Parameter(title: "Date", kind: .date)
    private var date: Date
    @Parameter(title: "Content")
    private var content: String
    @Parameter(title: "Income")
    private var income: IntentCurrencyAmount
    @Parameter(title: "Outgo")
    private var outgo: IntentCurrencyAmount
    @Parameter(title: "Category")
    private var category: String
    @Parameter(title: "Repeat", default: 1, inclusiveRange: (1, 60))
    private var repeatCount: Int

    @Dependency private var itemService: ItemService

    typealias Input = (date: Date, content: String, income: Decimal, outgo: Decimal, category: String, repeatCount: Int, itemService: ItemService)
    typealias Output = ItemEntity

    static func perform(_ input: Input) throws -> Output {
        let (date, content, income, outgo, category, repeatCount, itemService) = input
        let model = try itemService.create(
            date: date,
            content: content,
            income: income,
            outgo: outgo,
            category: category,
            repeatCount: repeatCount
        )
        guard let item = ItemEntity(model) else {
            throw DebugError.default
        }
        return item
    }

    func perform() throws -> some ReturnsValue<ItemEntity> {
        guard content.isNotEmpty else {
            throw $content.needsValueError()
        }

        let currencyCode = AppStorage(.currencyCode).wrappedValue
        guard income.currencyCode == currencyCode else {
            throw $income.needsDisambiguationError(among: [.init(amount: income.amount, currencyCode: currencyCode)])
        }
        guard outgo.currencyCode == currencyCode else {
            throw $outgo.needsDisambiguationError(among: [.init(amount: outgo.amount, currencyCode: currencyCode)])
        }

        let item = try Self.perform(
            (
                date: date,
                content: content,
                income: income.amount,
                outgo: outgo.amount,
                category: category,
                repeatCount: repeatCount,
                itemService: itemService
            )
        )
        return .result(value: item)
    }
}
