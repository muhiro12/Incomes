import MHPlatform
import SwiftData

enum ItemCreateCoordinator {
    // swiftlint:disable function_parameter_count
    @MainActor
    static func create(
        context: ModelContext,
        input: ItemFormInput,
        repeatCount: Int,
        notificationService: NotificationService,
        logger: MHLogger,
        reviewLogger: MHLogger
    ) async throws -> Item {
        try await run(
            context: context,
            notificationService: notificationService,
            logger: logger,
            reviewLogger: reviewLogger,
            metadata: IncomesLogging.metadata(
                ("mode", "repeat_count"),
                ("repeat_count", IncomesLogging.count(repeatCount)),
                ("category_present", IncomesLogging.presence(input.category)),
                ("content_present", IncomesLogging.presence(input.content))
            )
        ) {
            let result = try ItemCreationOperations.createWithOutcome(
                context: context,
                input: input,
                repeatCount: repeatCount
            )
            return .init(
                value: result.value.persistentModelID,
                outcome: result.outcome
            )
        }
    }

    @MainActor
    static func create(
        context: ModelContext,
        input: ItemFormInput,
        repeatMonthSelections: Set<RepeatMonthSelection>,
        notificationService: NotificationService,
        logger: MHLogger,
        reviewLogger: MHLogger
    ) async throws -> Item {
        try await run(
            context: context,
            notificationService: notificationService,
            logger: logger,
            reviewLogger: reviewLogger,
            metadata: IncomesLogging.metadata(
                ("mode", "repeat_months"),
                ("repeat_month_count", IncomesLogging.count(repeatMonthSelections.count)),
                ("category_present", IncomesLogging.presence(input.category)),
                ("content_present", IncomesLogging.presence(input.content))
            )
        ) {
            let result = try ItemCreationOperations.createWithOutcome(
                context: context,
                input: input,
                repeatMonthSelections: repeatMonthSelections
            )
            return .init(
                value: result.value.persistentModelID,
                outcome: result.outcome
            )
        }
    }

    @MainActor
    private static func run(
        context: ModelContext,
        notificationService: NotificationService,
        logger: MHLogger,
        reviewLogger: MHLogger,
        metadata: [String: String],
        operation: @escaping @MainActor () throws -> MutationResult<PersistentIdentifier>
    ) async throws -> Item {
        logger.notice(
            "item_create.requested",
            metadata: metadata
        )

        do {
            let itemID = try await runCreateWorkflow(
                notificationService: notificationService,
                reviewLogger: reviewLogger,
                logger: logger,
                operation: operation
            )
            let item = try createdItem(
                context: context,
                itemID: itemID,
                metadata: metadata,
                logger: logger
            )
            logCompletedCreation(
                metadata: metadata,
                logger: logger
            )
            return item
        } catch {
            logger.error(
                "item_create.failed",
                metadata: failureMetadata(metadata, error: error)
            )
            throw error
        }
    }
    // swiftlint:enable function_parameter_count
}

private extension ItemCreateCoordinator {
    @MainActor
    static func runCreateWorkflow(
        notificationService: NotificationService,
        reviewLogger: MHLogger,
        logger: MHLogger,
        operation: @escaping @MainActor () throws -> MutationResult<PersistentIdentifier>
    ) async throws -> PersistentIdentifier {
        try await MHMutationWorkflow.runThrowing(
            name: ItemMutationWorkflowName.create,
            operation: operation,
            adapter: ItemMutationAdapterFactory.makeForSave(
                notificationService: notificationService,
                reviewLogger: reviewLogger
            ),
            projection: .valueAndFollowUp(
                value: \.value,
                followUp: \.outcome.followUpHints
            ),
            onEvent: MHMutationWorkflowLogger(logger: logger).onEvent()
        )
    }

    static func createdItem(
        context: ModelContext,
        itemID: PersistentIdentifier,
        metadata: [String: String],
        logger: MHLogger
    ) throws -> Item {
        guard let item = try ItemQueryOperations.item(
            context: context,
            persistentID: itemID
        ) else {
            logger.error(
                "item_create.failed",
                metadata: missingCreatedItemMetadata(metadata)
            )
            throw ItemError.itemNotFound
        }

        return item
    }

    static func logCompletedCreation(
        metadata: [String: String],
        logger: MHLogger
    ) {
        logger.notice(
            "item_create.completed",
            metadata: createdItemMetadata(metadata)
        )
    }

    static func createdItemMetadata(
        _ metadata: [String: String]
    ) -> [String: String] {
        metadata.merging(
            IncomesLogging.metadata(
                ("item_id_present", "true")
            )
        ) { current, _ in
            current
        }
    }

    static func missingCreatedItemMetadata(
        _ metadata: [String: String]
    ) -> [String: String] {
        metadata.merging(
            IncomesLogging.metadata(
                ("phase", "fetch_created_item"),
                ("item_id_present", "true")
            )
        ) { current, _ in
            current
        }
    }

    static func failureMetadata(
        _ metadata: [String: String],
        error: any Error
    ) -> [String: String] {
        metadata.merging(IncomesLogging.errorMetadata(error)) { current, _ in
            current
        }
    }
}
