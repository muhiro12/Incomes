import MHPlatform
import SwiftData

enum UpdateItemIntentMutationPerformer {
    // swiftlint:disable function_parameter_count
    @MainActor
    static func perform(
        context: ModelContext,
        item: Item,
        input: ItemFormInput,
        scope: ItemMutationScope,
        notificationService: NotificationService,
        logger: MHLogger,
        reviewLogger: MHLogger
    ) async throws -> ItemEntity {
        try await ItemFormSaveCoordinator.save(
            scope: scope,
            context: context,
            item: item,
            formInputData: input,
            notificationService: notificationService,
            logger: logger,
            reviewLogger: reviewLogger
        )
        guard let entity = ItemEntity(item) else {
            throw ItemError.entityConversionFailed
        }
        return entity
    }
    // swiftlint:enable function_parameter_count
}
