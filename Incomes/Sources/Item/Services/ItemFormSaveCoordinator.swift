//
//  ItemFormSaveCoordinator.swift
//  Incomes
//
//  Created by Codex on 2025/09/08.
//

import MHPlatform
import SwiftData

enum ItemFormSaveCoordinator {
    struct Request {
        let mode: ItemFormSaveMode
        let item: Item?
        let formInputData: ItemFormInput
        let repeatMonthSelections: Set<RepeatMonthSelection>
    }

    @MainActor
    static func save(
        context: ModelContext,
        request: Request,
        notificationService: NotificationService,
        logger: MHLogger,
        reviewLogger: MHLogger
    ) async throws -> ItemFormSaveOutcome {
        switch request.mode {
        case .create:
            _ = try await ItemCreateCoordinator.create(
                context: context,
                input: request.formInputData,
                repeatMonthSelections: request.repeatMonthSelections,
                notificationService: notificationService,
                logger: logger,
                reviewLogger: reviewLogger
            )
            return .didSave
        case .edit:
            guard let item = request.item else {
                logger.error(
                    "item_save.failed",
                    metadata: IncomesLogging.metadata(
                        ("mode", "edit"),
                        ("failure_reason", "missing_item")
                    )
                )
                throw ItemError.itemNotFound
            }
            if try ItemFormSaveDecision.requiresScopeSelection(
                context: context,
                item: item
            ) {
                logger.notice(
                    "item_save.scope_selection_required",
                    metadata: IncomesLogging.metadata(
                        ("mode", "edit"),
                        ("item_id_present", "true")
                    )
                )
                return .requiresScopeSelection
            }
            try await save(
                scope: .thisItem,
                context: context,
                item: item,
                formInputData: request.formInputData,
                notificationService: notificationService,
                logger: logger,
                reviewLogger: reviewLogger
            )
            return .didSave
        }
    }

    // swiftlint:disable function_parameter_count
    @MainActor
    static func save(
        scope: ItemMutationScope,
        context: ModelContext,
        item: Item,
        formInputData: ItemFormInput,
        notificationService: NotificationService,
        logger: MHLogger,
        reviewLogger: MHLogger
    ) async throws {
        let metadata = IncomesLogging.metadata(
            ("mode", "edit"),
            ("scope", scope.logValue),
            ("item_id_present", "true"),
            ("category_present", IncomesLogging.presence(formInputData.category)),
            ("content_present", IncomesLogging.presence(formInputData.content))
        )
        logger.notice(
            "item_save.requested",
            metadata: metadata
        )

        do {
            _ = try await MHMutationWorkflow.runThrowing(
                name: mutationName(for: scope),
                operation: {
                    try ItemUpdateOperations.updateWithOutcome(
                        context: context,
                        item: item,
                        input: formInputData,
                        scope: scope
                    )
                },
                adapter: ItemMutationAdapterFactory.makeForSave(
                    notificationService: notificationService,
                    reviewLogger: reviewLogger
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
            logger.notice(
                "item_save.completed",
                metadata: metadata
            )
        } catch {
            logger.error(
                "item_save.failed",
                metadata: metadata.merging(IncomesLogging.errorMetadata(error)) { current, _ in
                    current
                }
            )
            throw error
        }
    }
    // swiftlint:enable function_parameter_count

    private static func mutationName(
        for scope: ItemMutationScope
    ) -> String {
        switch scope {
        case .thisItem:
            ItemMutationWorkflowName.updateThisItem
        case .futureItems:
            ItemMutationWorkflowName.updateFutureItems
        case .allItems:
            ItemMutationWorkflowName.updateAllItems
        }
    }
}

private extension ItemMutationScope {
    var logValue: String {
        switch self {
        case .thisItem:
            "this_item"
        case .futureItems:
            "future_items"
        case .allItems:
            "all_items"
        }
    }
}
