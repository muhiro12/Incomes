import MHPlatform
import SwiftData

enum ItemDeleteCoordinator {
    @MainActor
    static func delete(
        context: ModelContext,
        item: Item,
        notificationService: NotificationService
    ) async throws {
        try await delete(
            context: context,
            items: [item],
            notificationService: notificationService
        )
    }

    @MainActor
    static func delete(
        context: ModelContext,
        items: [Item],
        notificationService: NotificationService
    ) async throws {
        guard items.isNotEmpty else {
            return
        }

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
    }
}
