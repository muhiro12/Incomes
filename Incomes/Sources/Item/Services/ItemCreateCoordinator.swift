import MHPlatform
import SwiftData

enum ItemCreateCoordinator {
    @MainActor
    static func create(
        context: ModelContext,
        input: ItemFormInput,
        repeatCount: Int,
        notificationService: NotificationService
    ) async throws -> Item {
        try await run(
            context: context,
            notificationService: notificationService
        ) {
            let result = try ItemService.createWithOutcome(
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
        notificationService: NotificationService
    ) async throws -> Item {
        try await run(
            context: context,
            notificationService: notificationService
        ) {
            let result = try ItemService.createWithOutcome(
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
        operation: @escaping @MainActor () throws -> MutationResult<PersistentIdentifier>
    ) async throws -> Item {
        let itemID = try await MHMutationWorkflow.runThrowing(
            name: ItemMutationWorkflowName.create,
            operation: operation,
            adapter: ItemMutationAdapterFactory.make(
                notificationService: notificationService,
                includesReviewRequest: true
            ),
            projection: .keyPaths(
                adapterValue: \.outcome.followUpHints,
                resultValue: \.value
            )
        )

        guard let item = try context.fetch(.items(.idIs(itemID), order: .forward)).first else {
            throw ItemError.itemNotFound
        }

        return item
    }
}
