//
//  CreateAndShowItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//

import AppIntents
import SwiftData

struct CreateAndShowItemIntent: AppIntent {
    @Parameter(title: "Date", kind: .date)
    private var date: Date // swiftlint:disable:this type_contents_order
    @Parameter(title: "Content")
    private var content: String // swiftlint:disable:this type_contents_order
    @Parameter(title: "Income")
    private var income: Double // swiftlint:disable:this type_contents_order
    @Parameter(title: "Outgo")
    private var outgo: Double // swiftlint:disable:this type_contents_order
    @Parameter(title: "Category")
    private var category: String // swiftlint:disable:this type_contents_order
    @Parameter(title: "Repeat", default: 1, inclusiveRange: (1, 60)) // swiftlint:disable:this no_magic_numbers
    private var repeatCount: Int // swiftlint:disable:this type_contents_order

    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Create and Show Item", table: "AppIntents")

    private var formInput: ItemFormInput {
        .init(
            date: date,
            content: content,
            incomeText: Decimal(income).description,
            outgoText: Decimal(outgo).description,
            category: category,
            priorityText: "0"
        )
    }

    @MainActor
    func perform() throws -> some ProvidesDialog & ShowsSnippetView {
        do {
            try formInput.validate()
        } catch ItemFormInput.ValidationError.contentIsEmpty {
            throw ItemError.contentIsEmpty
        }
        let item = try ItemService.create(
            context: modelContainer.mainContext,
            input: formInput,
            repeatCount: repeatCount
        )
        return .result(
            opensIntent: IncomesIntentRouteOpener.monthIntent(for: item.localDate),
            dialog: .init(stringLiteral: item.content)
        ) {
            IntentItemSection()
                .environment(item)
        }
    }
}
