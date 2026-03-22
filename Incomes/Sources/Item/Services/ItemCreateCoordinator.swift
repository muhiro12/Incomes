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
            try ItemService.createWithOutcome(
                context: context,
                input: input,
                repeatCount: repeatCount
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
            try ItemService.createWithOutcome(
                context: context,
                input: input,
                repeatMonthSelections: repeatMonthSelections
            )
        }
    }

    @MainActor
    private static func run(
        context _: ModelContext,
        notificationService: NotificationService,
        operation: @escaping @MainActor () throws -> MutationResult<Item>
    ) async throws -> Item {
        try await MHMutationWorkflow.runThrowing(
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
    }
}
