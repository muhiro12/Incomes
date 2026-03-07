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

    struct Workflow {
        let refreshNotificationSchedule: IncomesMutationWorkflow.NotificationScheduleRefresher
        let requestReviewIfNeeded: IncomesMutationWorkflow.ReviewRequester
    }

    private enum MutationName {
        static let create = "createItem"
        static let updateThisItem = "updateItem.thisItem"
        static let updateFutureItems = "updateItem.futureItems"
        static let updateAllItems = "updateItem.allItems"
    }

    @MainActor
    static func save(
        context: ModelContext,
        request: Request,
        workflow: Workflow
    ) async throws -> ItemFormSaveOutcome {
        let adapter = IncomesMutationWorkflow.itemFormAdapter(
            refreshNotificationSchedule: workflow.refreshNotificationSchedule,
            requestReviewIfNeeded: workflow.requestReviewIfNeeded
        )

        switch request.mode {
        case .create:
            _ = try await IncomesMutationWorkflow.run(
                name: MutationName.create,
                operation: {
                    try ItemService.createWithOutcome(
                        context: context,
                        input: request.formInputData,
                        repeatMonthSelections: request.repeatMonthSelections
                    )
                },
                adapter: adapter,
                afterSuccess: { result in
                    result.outcome.followUpHints
                },
                returning: { _ in
                    ()
                }
            )
            return .didSave
        case .edit:
            guard let item = request.item else {
                assertionFailure()
                return .didSave
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
                workflow: workflow
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
        workflow: Workflow
    ) async throws {
        _ = try await IncomesMutationWorkflow.run(
            name: mutationName(for: scope),
            operation: {
                try ItemService.updateWithOutcome(
                    context: context,
                    item: item,
                    input: formInputData,
                    scope: scope
                )
            },
            adapter: IncomesMutationWorkflow.itemFormAdapter(
                refreshNotificationSchedule: workflow.refreshNotificationSchedule,
                requestReviewIfNeeded: workflow.requestReviewIfNeeded
            ),
            afterSuccess: { outcome in
                outcome.followUpHints
            },
            returning: { _ in
                ()
            }
        )
    }

    private static func mutationName(
        for scope: ItemMutationScope
    ) -> String {
        switch scope {
        case .thisItem:
            MutationName.updateThisItem
        case .futureItems:
            MutationName.updateFutureItems
        case .allItems:
            MutationName.updateAllItems
        }
    }
}
