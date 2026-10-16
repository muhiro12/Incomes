//
//  SettingsActionCoordinator.swift
//  Incomes
//
//  Created by Codex on 2025/09/08.
//

import SwiftData

enum SettingsActionCoordinator {
    static func loadStatus(context: ModelContext, ledgerIdentifier: LedgerIdentifier = .default) throws
    -> SettingsStatus {
        try SettingsStatusOperations.load(context: context, ledgerIdentifier: ledgerIdentifier)
    }

    static func refreshNotifications(notificationService: NotificationService) async {
        await IncomesMutationWorkflow.refreshNotificationSchedule(
            notificationService: notificationService
        )
    }
}
