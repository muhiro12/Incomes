//
//  SettingsActionCoordinator.swift
//  Incomes
//
//  Created by Codex on 2025/09/08.
//

import SwiftData

enum SettingsActionCoordinator {
    static func loadStatus(context: ModelContext) throws -> SettingsStatus {
        try SettingsStatusOperations.load(context: context)
    }

    static func resetAllData(
        context: ModelContext,
        notificationService: NotificationService
    ) async throws {
        try await DataMaintenanceOperations.resetAllData(context: context)
        await IncomesMutationWorkflow.refreshAllDataSurfaces(
            notificationService: notificationService
        )
    }

    static func refreshNotifications(notificationService: NotificationService) async {
        await IncomesMutationWorkflow.refreshNotificationSchedule(
            notificationService: notificationService
        )
    }
}
