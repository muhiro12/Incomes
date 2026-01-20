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

    static func deleteAllData(context: ModelContext) throws {
        try ItemService.deleteAll(context: context)
        try TagService.deleteAll(context: context)
        Haptic.success.impact()
    }

    static func deleteDebugData(context: ModelContext) throws {
        try ItemService.deleteDebugData(context: context)
        Haptic.success.impact()
    }

    static func refreshNotifications(notificationService: NotificationService) async {
        notificationService.refresh()
        await notificationService.register()
    }
}
