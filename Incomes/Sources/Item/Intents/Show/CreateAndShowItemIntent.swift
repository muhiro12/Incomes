//
//  CreateAndShowItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/10.
//

import AppIntents
import MHPlatform
import SwiftData

struct CreateAndShowItemIntent: AppIntent {
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
    @Dependency private var notificationService: NotificationService // swiftlint:disable:this type_contents_order
    @Dependency private var logging: MHLoggingBootstrap // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Create and Show Item", table: "AppIntents")

    private var formInput: ItemFormInput {
        .init(
            date: date,
            content: content,
            income: income.amount,
            outgo: outgo.amount,
            category: category
        )
    }

    @MainActor
    func perform() async throws -> some ProvidesDialog & ShowsSnippetView {
        try ItemIntentFormInputSupport.validate(
            formInput: formInput,
            contentParameter: $content
        )
        try ItemIntentCurrencySupport.validate(
            income: income,
            incomeParameter: $income,
            outgo: outgo,
            outgoParameter: $outgo
        )

        let item = try await ItemIntentMutationSupport.createModel(
            context: modelContainer.mainContext,
            input: formInput,
            repeatCount: repeatCount,
            notificationService: notificationService,
            logger: intentLogger,
            reviewLogger: reviewLogger
        )
        return ItemIntentShowResultSupport.singleItem(
            item,
            defaultDate: item.localDate
        )
    }
}

private extension CreateAndShowItemIntent {
    @MainActor var intentLogger: MHLogger {
        IncomesIntentLoggingSupport.appIntentLogger(
            logging: logging,
            source: #fileID
        )
    }

    @MainActor var reviewLogger: MHLogger {
        IncomesIntentLoggingSupport.reviewFlowLogger(
            logging: logging,
            source: #fileID
        )
    }
}
