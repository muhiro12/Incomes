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
    private var date: Date
    @Parameter(title: "Content")
    private var content: String
    @Parameter(title: "Income")
    private var income: Double
    @Parameter(title: "Outgo")
    private var outgo: Double
    @Parameter(title: "Category")
    private var category: String
    @Parameter(title: "Repeat", default: 1, inclusiveRange: (1, 60))
    private var repeatCount: Int

    @Dependency private var modelContainer: ModelContainer

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
        guard content.isNotEmpty else {
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
