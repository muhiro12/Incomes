//
//  CreateItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData
import SwiftUI
import SwiftUtilities

struct CreateItemIntent: AppIntent, IntentPerformer {
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

    @Dependency private var modelContainer: ModelContainer

    typealias Input = (context: ModelContext, date: Date, content: String, income: Decimal, outgo: Decimal, category: String, repeatCount: Int)
    typealias Output = ItemEntity

    static func perform(_ input: Input) throws -> Output {
        let (context, date, content, income, outgo, category, repeatCount) = input
        var items = [Item]()

        let repeatID = UUID()

        let model = try Item.create(
            context: context,
            date: date,
            content: content,
            income: income,
            outgo: outgo,
            category: category,
            repeatID: repeatID
        )
        items.append(model)

        for index in 0..<repeatCount {
            guard index > .zero else {
                continue
            }
            guard let repeatingDate = Calendar.current.date(byAdding: .month,
                                                            value: index,
                                                            to: date) else {
                assertionFailure()
                continue
            }
            let item = try Item.create(
                context: context,
                date: repeatingDate,
                content: content,
                income: income,
                outgo: outgo,
                category: category,
                repeatID: repeatID
            )
            items.append(item)
        }

        items.forEach(context.insert)

        let calculator = BalanceCalculator()
        try calculator.calculate(in: context, for: items)

        guard let entity = ItemEntity(model) else {
            throw ItemError.entityConversionFailed
        }
        return entity
    }

    @MainActor
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
                context: modelContainer.mainContext,
                date: date,
                content: content,
                income: income.amount,
                outgo: outgo.amount,
                category: category,
                repeatCount: repeatCount
            )
        )
        return .result(value: item)
    }
}
