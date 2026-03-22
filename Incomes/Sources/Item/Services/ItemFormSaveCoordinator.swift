//
//  ItemFormSaveCoordinator.swift
//  Incomes
//
//  Created by Codex on 2025/09/08.
//

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
            let result = try ItemService.createWithOutcome(
                context: context,
                input: request.formInputData,
                repeatMonthSelections: request.repeatMonthSelections
            )
            await performFollowUpHints(
                result.outcome.followUpHints,
                notificationService: notificationService
            )
            Haptic.success.impact()
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
        let outcome = try ItemService.updateWithOutcome(
            context: context,
            item: item,
            input: formInputData,
            scope: scope
        )
        await performFollowUpHints(
            outcome.followUpHints,
            notificationService: notificationService
        )
        Haptic.success.impact()
    }
}

private extension ItemFormSaveCoordinator {
    @MainActor
    static func performFollowUpHints(
        _ followUpHints: Set<MutationOutcome.FollowUpHint>,
        notificationService: NotificationService
    ) async {
        let refreshNotificationSchedule: IncomesMutationWorkflow.NotificationScheduleRefresher = {
            await IncomesMutationWorkflow.refreshNotificationSchedule(
                notificationService: notificationService
            )
        }

        await IncomesMutationWorkflow.perform(
            followUpHints: followUpHints,
            refreshNotificationSchedule: refreshNotificationSchedule
        )
    }
}
