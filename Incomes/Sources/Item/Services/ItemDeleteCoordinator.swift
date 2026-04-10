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

    // swiftlint:disable function_body_length
    @MainActor
    static func delete(
        context: ModelContext,
        items: [Item],
        notificationService: NotificationService,
        logger: MHLogger
    ) async throws {
        guard items.isNotEmpty else {
            logger.info(
                "item_delete.skipped",
                metadata: IncomesLogging.metadata(
                    ("item_count", "0")
                )
            )
            return
        }

        let metadata = IncomesLogging.metadata(
            ("item_count", IncomesLogging.count(items.count))
        )
        logger.notice(
            "item_delete.requested",
            metadata: metadata
        )

        do {
            _ = try await MHMutationWorkflow.runThrowing(
                name: items.count == 1
                    ? ItemMutationWorkflowName.deleteItem
                    : ItemMutationWorkflowName.deleteItems,
                operation: {
                    try ItemService.deleteWithOutcome(
                        context: context,
                        items: items
                    )
                },
                adapter: ItemMutationAdapterFactory.make(
                    notificationService: notificationService,
                    includesReviewRequest: false
                ),
                projection: .closures(
                    afterSuccess: { outcome in
                        outcome.followUpHints
                    },
                    returning: { _ in
                        ()
                    }
                )
            )
            logger.notice(
                "item_delete.completed",
                metadata: metadata
            )
        } catch {
            logger.error(
                "item_delete.failed",
                metadata: metadata.merging(IncomesLogging.errorMetadata(error)) { current, _ in
                    current
                }
            )
            throw error
        }
    }
    // swiftlint:enable function_body_length
}
