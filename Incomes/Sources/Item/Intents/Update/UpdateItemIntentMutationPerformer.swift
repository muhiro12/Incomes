import SwiftData

enum UpdateItemIntentMutationPerformer {
    @MainActor
    static func perform(
        context: ModelContext,
        item: Item,
        input: ItemFormInput,
        scope: ItemMutationScope,
        notificationService: NotificationService
    ) async throws -> ItemEntity {
        try await ItemFormSaveCoordinator.save(
            scope: scope,
            context: context,
            item: item,
            formInputData: input,
            notificationService: notificationService
        )
        guard let entity = ItemEntity(item) else {
            throw ItemError.entityConversionFailed
        }
        return entity
    }
}
