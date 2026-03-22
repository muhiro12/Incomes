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
        notificationService: NotificationService
    ) async throws -> ItemFormSaveOutcome {
        switch request.mode {
        case .create:
            _ = try await MHMutationWorkflow.runThrowing(
                name: MutationName.create,
                operation: {
                    try ItemService.createWithOutcome(
                        context: context,
                        input: request.formInputData,
                        repeatMonthSelections: request.repeatMonthSelections
                    )
                },
                adapter: itemFormAdapter(
                    notificationService: notificationService
                ),
                projection: .closures(
                    afterSuccess: { result in
                        result.outcome.followUpHints
                    },
                    returning: { _ in
                        ()
                    }
                )
            )
            return .didSave
        case .edit:
            guard let item = request.item else {
                assertionFailure()
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
            adapter: itemFormAdapter(
                notificationService: notificationService
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
            MutationName.updateThisItem
        case .futureItems:
            MutationName.updateFutureItems
        case .allItems:
            MutationName.updateAllItems
        }
    }

    @MainActor
    private static func itemFormAdapter(
        notificationService: NotificationService
    ) -> MHMutationAdapter<Set<MutationOutcome.FollowUpHint>> {
        let refreshNotificationSchedule: IncomesMutationWorkflow.NotificationScheduleRefresher = {
            await IncomesMutationWorkflow.refreshNotificationSchedule(
                notificationService: notificationService
            )
        }
        let adapter = IncomesMutationWorkflow.followUpHintAdapter(
            refreshNotificationSchedule: refreshNotificationSchedule
        )
        let reviewFlow = IncomesReviewSupport.flow(
            context: .itemMutation,
            source: #fileID
        )
        let reviewStep = reviewFlow.step(
            name: "scheduleReviewRequest"
        )

        return adapter.appending(
            [
                .mainActor(name: "successHaptic") {
                    Haptic.success.impact()
                },
                reviewStep
            ]
        )
    }
}
