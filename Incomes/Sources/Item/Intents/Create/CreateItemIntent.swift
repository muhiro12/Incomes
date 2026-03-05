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
        try validateFormInput()

        let currencyCode = AppStorage(.currencyCode).wrappedValue
        if let amount = ItemIntentCurrencyValidator.disambiguationAmount(
            amount: income,
            expectedCurrencyCode: currencyCode
        ) {
            throw $income.needsDisambiguationError(among: [amount])
        }
        if let amount = ItemIntentCurrencyValidator.disambiguationAmount(
            amount: outgo,
            expectedCurrencyCode: currencyCode
        ) {
            throw $outgo.needsDisambiguationError(among: [amount])
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

private extension CreateItemIntent {
    func validateFormInput() throws {
        do {
            try formInput.validate()
        } catch ItemFormInput.ValidationError.contentIsEmpty {
            throw $content.needsValueError()
        } catch {
            throw error
        }
    }
}
