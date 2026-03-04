//
//  SettingsActionCoordinator.swift
//  Incomes
//
//  Created by Codex on 2025/09/08.
//

import SwiftData

enum SettingsActionCoordinator {
    static func loadStatus(context: ModelContext) throws -> SettingsStatus {
        try SettingsStatusLoader.load(context: context)
    }

    static func refreshNotifications(notificationService: NotificationService) async {
        await notificationService.refresh()
        await notificationService.register()
    }
}
