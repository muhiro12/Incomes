//
//  CreateItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//

import AppIntents
import SwiftData
import SwiftUI

struct CreateItemIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date // swiftlint:disable:this type_contents_order
    @Parameter(title: "Content")
    private var content: String // swiftlint:disable:this type_contents_order
    @Parameter(title: "Income")
    private var income: IntentCurrencyAmount // swiftlint:disable:this type_contents_order
    @Parameter(title: "Outgo")
    private var outgo: IntentCurrencyAmount // swiftlint:disable:this type_contents_order
    @Parameter(title: "Category")
    private var category: String // swiftlint:disable:this type_contents_order
    @Parameter(title: "Repeat", default: 1, inclusiveRange: (1, 60)) // swiftlint:disable:this no_magic_numbers
    private var repeatCount: Int // swiftlint:disable:this type_contents_order

    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Create Item", table: "AppIntents")

    private var formInput: ItemFormInput {
        .init(
            date: date,
            content: content,
            incomeText: income.amount.description,
            outgoText: outgo.amount.description,
            category: category,
            priorityText: "0"
        )
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

        let item = try ItemService.create(
            context: modelContainer.mainContext,
            input: formInput,
            repeatCount: repeatCount
        )
        guard let entity = ItemEntity(item) else {
            throw ItemError.entityConversionFailed
        }
        return .result(value: entity)
    }
}
