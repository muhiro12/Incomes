import Foundation
import MHPlatform
import SwiftData

enum ItemIntentMutationSupport {
    // swiftlint:disable function_parameter_count
    @MainActor
    static func createEntity(
        context: ModelContext,
        input: ItemFormInput,
        repeatCount: Int,
        notificationService: NotificationService,
        logger: MHLogger,
        reviewLogger: MHLogger
    ) async throws -> ItemEntity {
        let item = try await ItemCreateCoordinator.create(
            context: context,
            input: input,
            repeatCount: repeatCount,
            notificationService: notificationService,
            logger: logger,
            reviewLogger: reviewLogger
        )
        return try ItemEntity.make(from: item)
    }

    @MainActor
    static func createScheduledEntity(
        context: ModelContext,
        input: ItemFormInput,
        repeatMonthSelections: Set<RepeatMonthSelection>,
        notificationService: NotificationService,
        logger: MHLogger,
        reviewLogger: MHLogger
    ) async throws -> ItemEntity {
        let item = try await ItemCreateCoordinator.create(
            context: context,
            input: input,
            repeatMonthSelections: repeatMonthSelections,
            notificationService: notificationService,
            logger: logger,
            reviewLogger: reviewLogger
        )
        return try ItemEntity.make(from: item)
    }

    @MainActor
    static func createModel(
        context: ModelContext,
        input: ItemFormInput,
        repeatCount: Int,
        notificationService: NotificationService,
        logger: MHLogger,
        reviewLogger: MHLogger
    ) async throws -> Item {
        try await ItemCreateCoordinator.create(
            context: context,
            input: input,
            repeatCount: repeatCount,
            notificationService: notificationService,
            logger: logger,
            reviewLogger: reviewLogger
        )
    }

    @MainActor
    static func updateEntity(
        context: ModelContext,
        item: ItemEntity,
        input: ItemFormInput,
        scope: ItemMutationScope,
        notificationService: NotificationService,
        logger: MHLogger,
        reviewLogger: MHLogger
    ) async throws -> ItemEntity {
        let model = try item.model(in: context)
        try await ItemFormSaveCoordinator.save(
            scope: scope,
            context: context,
            item: model,
            formInputData: input,
            notificationService: notificationService,
            logger: logger,
            reviewLogger: reviewLogger
        )
        return try ItemEntity.make(from: model)
    }

    @MainActor
    static func delete(
        item: ItemEntity,
        context: ModelContext,
        notificationService: NotificationService,
        logger: MHLogger
    ) async throws {
        try await ItemDeleteCoordinator.delete(
            context: context,
            item: item.model(in: context),
            notificationService: notificationService,
            logger: logger
        )
    }

    @MainActor
    static func recalculateBalances(
        context: ModelContext,
        date: Date
    ) throws {
        try ItemBalanceOperations.recalculate(
            context: context,
            date: date
        )
    }
    // swiftlint:enable function_parameter_count
}
