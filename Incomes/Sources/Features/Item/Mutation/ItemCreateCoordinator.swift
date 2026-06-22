import MHPlatform
import SwiftData

enum ItemCreateCoordinator {
    @MainActor
    static func create(
        context: ModelContext,
        input: ItemFormInput,
        repeatCount: Int,
        dependencies: ItemMutationWorkflowDependencies
    ) async throws -> Item {
        try await run(
            context: context,
            dependencies: dependencies,
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
        dependencies: ItemMutationWorkflowDependencies
    ) async throws -> Item {
        try await run(
            context: context,
            dependencies: dependencies,
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
        dependencies: ItemMutationWorkflowDependencies,
        metadata: [String: String],
        operation: @escaping @MainActor () throws -> MutationResult<PersistentIdentifier>
    ) async throws -> Item {
        dependencies.logger.notice(
            "item_create.requested",
            metadata: metadata
        )

        do {
            let itemID = try await runCreateWorkflow(
                dependencies: dependencies,
                operation: operation
            )
            let item = try createdItem(
                context: context,
                itemID: itemID,
                metadata: metadata,
                logger: dependencies.logger
            )
            logCompletedCreation(
                metadata: metadata,
                logger: dependencies.logger
            )
            return item
        } catch {
            dependencies.logger.error(
                "item_create.failed",
                metadata: failureMetadata(metadata, error: error)
            )
            throw error
        }
    }
}

private extension ItemCreateCoordinator {
    @MainActor
    static func runCreateWorkflow(
        dependencies: ItemMutationWorkflowDependencies,
        operation: @escaping @MainActor () throws -> MutationResult<PersistentIdentifier>
    ) async throws -> PersistentIdentifier {
        try await MHMutationWorkflow.runThrowing(
            name: ItemMutationWorkflowName.create,
            operation: operation,
            adapter: ItemMutationAdapterFactory.makeForSave(
                notificationService: dependencies.notificationService,
                reviewLogger: dependencies.reviewLogger
            ),
            projection: .valueAndFollowUp(
                value: \.value,
                followUp: \.outcome.followUpHints
            ),
            onEvent: MHMutationWorkflowLogger(logger: dependencies.logger).onEvent()
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
