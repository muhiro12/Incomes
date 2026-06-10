import AppIntents
import MHPlatform
import SwiftData

struct UpdateItemIntent: AppIntent {
    @Parameter(title: "Item")
    private var item: ItemEntity // swiftlint:disable:this type_contents_order
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
    @Parameter(title: "Priority", default: 0, inclusiveRange: (0, 10)) // swiftlint:disable:this no_magic_numbers
    private var priority: Int // swiftlint:disable:this type_contents_order
    @Parameter(title: "Scope", default: .thisItem)
    private var scope: ItemMutationScopeIntentValue // swiftlint:disable:this type_contents_order

    @Dependency private var modelContainer: ModelContainer // swiftlint:disable:this type_contents_order
    @Dependency private var notificationService: NotificationService // swiftlint:disable:this type_contents_order
    @Dependency private var logging: MHLoggingBootstrap // swiftlint:disable:this type_contents_order

    static let title: LocalizedStringResource = .init("Update Item", table: "AppIntents")
    static let isDiscoverable = false

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
            notificationService: notificationService,
            logger: intentLogger,
            reviewLogger: reviewLogger
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
}
