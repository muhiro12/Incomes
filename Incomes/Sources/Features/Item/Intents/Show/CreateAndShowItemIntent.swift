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
    static let title: LocalizedStringResource = .init("Create and Show Item", table: "AppIntents")

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
    // App Intents requires compile-time literals for parameter metadata.
    @Parameter(title: "Repeat", default: 1, inclusiveRange: (1, 60)) // swiftlint:disable:this no_magic_numbers
    private var repeatCount: Int

    @Dependency private var modelContainer: ModelContainer
    @Dependency private var notificationService: NotificationService
    @Dependency private var logging: MHLoggingBootstrap

    @MainActor private var formInput: ItemFormInput {
        ItemIntentFormInputSupport.formInput(
            date: date,
            content: content,
            income: income,
            outgo: outgo,
            category: category
        )
    }

    @MainActor
    func perform() async throws -> some ProvidesDialog & ShowsSnippetView {
        try ItemIntentFormInputSupport.validate(
            formInput: formInput,
            income: income,
            outgo: outgo,
            parameters: .init(
                content: $content,
                income: $income,
                outgo: $outgo
            )
        )

        let item = try await ItemCreateCoordinator.create(
            context: modelContainer.mainContext,
            input: formInput,
            repeatCount: repeatCount,
            dependencies: mutationDependencies
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

    @MainActor var mutationDependencies: ItemMutationWorkflowDependencies {
        .init(
            notificationService: notificationService,
            logger: intentLogger,
            reviewLogger: reviewLogger
        )
    }
}
