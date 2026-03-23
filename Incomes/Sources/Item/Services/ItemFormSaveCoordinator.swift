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
        notificationService: NotificationService
    ) async throws -> ItemFormSaveOutcome {
        switch request.mode {
        case .create:
            _ = try await ItemCreateCoordinator.create(
                context: context,
                input: request.formInputData,
                repeatMonthSelections: request.repeatMonthSelections,
                notificationService: notificationService
            )
            return .didSave
        case .edit:
            guard let item = request.item else {
                throw ItemError.itemNotFound
            }
            if try ItemFormSaveDecision.requiresScopeSelection(
                context: context,
                item: item
            ) {
                return .requiresScopeSelection
            }
            try await save(
                scope: .thisItem,
                context: context,
                item: item,
                formInputData: request.formInputData,
                notificationService: notificationService
            )
            return .didSave
        }
    }

    @MainActor
    static func save(
        scope: ItemMutationScope,
        context: ModelContext,
        item: Item,
        formInputData: ItemFormInput,
        notificationService: NotificationService
    ) async throws {
        _ = try await MHMutationWorkflow.runThrowing(
            name: mutationName(for: scope),
            operation: {
                try ItemService.updateWithOutcome(
                    context: context,
                    item: item,
                    input: formInputData,
                    scope: scope
                )
            },
            adapter: ItemMutationAdapterFactory.make(
                notificationService: notificationService,
                includesReviewRequest: true
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
