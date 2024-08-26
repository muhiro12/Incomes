//
//  NotificationService.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2024/05/31.
//  Copyright © 2024 Hiromu Nakano. All rights reserved.
//

import Foundation
import UserNotifications

@MainActor
@Observable
final class NotificationService: NSObject {
    private(set) var hasNotification = false
    private(set) var shouldShowNotification = false

    private var center: UNUserNotificationCenter {
        UNUserNotificationCenter.current()
    }

    override init() {
        super.init()
        center.delegate = self
    }

    // Currently unused
    func register() async {
        _ = try? await center.requestAuthorization(
            options: [.badge, .sound, .alert, .carPlay]
        )

        center.removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.title = ""
        content.body = ""
        content.badge = 1
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        try? await center.add(request)
    }

    func update() async {
        hasNotification = await center.deliveredNotifications().isNotEmpty
    }

    func refresh() {
        center.setBadgeCount(0)
        center.removeAllDeliveredNotifications()
        hasNotification = false
        shouldShowNotification = false
    }
}

extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        hasNotification = true
        return [.badge, .sound, .list, .banner]
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        shouldShowNotification = true
    }
}
