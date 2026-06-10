//
//  CreateItemIntent.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/23.
//

import AppIntents
import MHPlatform
import SwiftData

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
    @Dependency private var notificationService: NotificationService // swiftlint:disable:this type_contents_order
    @Dependency private var logging: MHLoggingBootstrap // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Create Item", table: "AppIntents")

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
    func perform() async throws -> some ReturnsValue<ItemEntity> {
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
            notificationService: notificationService,
            logger: intentLogger,
            reviewLogger: reviewLogger
        )
        return .result(value: try ItemEntity.make(from: item))
    }
}

private extension CreateItemIntent {
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
