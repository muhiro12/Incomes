import MHPlatform
import SwiftData

enum ItemDeleteCoordinator {
    @MainActor
    static func delete(
        context: ModelContext,
        item: Item,
        notificationService: NotificationService,
        logger: MHLogger
    ) async throws {
        try await delete(
            context: context,
            items: [item],
            notificationService: notificationService,
            logger: logger
        )
    }

    @MainActor
    static func delete(
        context: ModelContext,
        items: [Item],
        notificationService: NotificationService,
        logger: MHLogger
    ) async throws {
        guard items.isNotEmpty else {
            logSkippedDelete(logger: logger)
            return
        }

        let metadata = deleteMetadata(for: items)
        logger.notice(
            "item_delete.requested",
            metadata: metadata
        )

        do {
            try await runDeleteWorkflow(
                context: context,
                items: items,
                notificationService: notificationService,
                logger: logger
            )
            logger.notice(
                "item_delete.completed",
                metadata: metadata
            )
        } catch {
            logger.error(
                "item_delete.failed",
                metadata: failureMetadata(metadata, error: error)
            )
            throw error
        }
    }
}

private extension ItemDeleteCoordinator {
    static func logSkippedDelete(
        logger: MHLogger
    ) {
        logger.info(
            "item_delete.skipped",
            metadata: IncomesLogging.metadata(
                ("item_count", "0")
            )
        )
    }

    @MainActor
    static func runDeleteWorkflow(
        context: ModelContext,
        items: [Item],
        notificationService: NotificationService,
        logger: MHLogger
    ) async throws {
        _ = try await MHMutationWorkflow.runThrowing(
            name: deleteWorkflowName(for: items),
            operation: {
                try ItemDeletionOperations.deleteWithOutcome(
                    context: context,
                    items: items
                )
            },
            adapter: ItemMutationAdapterFactory.makeForDelete(
                notificationService: notificationService
            ),
            projection: .closures(
                afterSuccess: { outcome in
                    outcome.followUpHints
                },
                returning: { _ in
                    ()
                }
            ),
            onEvent: MHMutationWorkflowLogger(logger: logger).onEvent()
        )
    }

    static func deleteWorkflowName(
        for items: [Item]
    ) -> String {
        items.count == 1
            ? ItemMutationWorkflowName.deleteItem
            : ItemMutationWorkflowName.deleteItems
    }

    static func deleteMetadata(
        for items: [Item]
    ) -> [String: String] {
        IncomesLogging.metadata(
            ("item_count", IncomesLogging.count(items.count))
        )
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
