import AppIntents
import MHPlatform
import SwiftData

struct UpdateItemIntent: AppIntent {
    static let title: LocalizedStringResource = .init("Update Item", table: "AppIntents")
    static let isDiscoverable = false

    @Parameter(title: "Item")
    private var item: ItemEntity
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
    @Parameter(title: "Priority", default: 0, inclusiveRange: (0, 10)) // swiftlint:disable:this no_magic_numbers
    private var priority: Int
    @Parameter(title: "Scope", default: .thisItem)
    private var scope: ItemMutationScopeIntentValue

    @Dependency private var modelContainer: ModelContainer
    @Dependency private var notificationService: NotificationService
    @Dependency private var logging: MHLoggingBootstrap

    @MainActor private var formInput: ItemFormInput {
        ItemIntentFormInputSupport.formInput(
            date: date,
            content: content,
            income: income,
            outgo: outgo,
            category: category,
            priority: priority
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
                outgo: $outgo,
                priority: $priority
            )
        )

        let context = modelContainer.mainContext
        let model = try item.model(in: context)
        try await ItemFormSaveCoordinator.save(
            scope: scope.scope,
            context: context,
            item: model,
            formInputData: formInput,
            dependencies: mutationDependencies
        )
        return .result(value: try ItemEntity.make(from: model))
    }
}

private extension UpdateItemIntent {
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
