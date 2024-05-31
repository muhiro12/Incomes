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

    func register() async {
        _ = try? await UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.badge, .sound, .alert, .carPlay])

        center.removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.title = .init(localized: "Important Subscription Update")
        content.body = .init(localized: "Starting August 1st, iCloud synchronization will be moved to the subscription plan. We appreciate your understanding and support.")
        content.badge = 1
        content.sound = .default

        for month in [6, 7, 8] {
            for day in [10, 20, 30] {
                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: .init(year: 2_024, month: month, day: day, hour: 20),
                    repeats: false
                )

                let request = UNNotificationRequest(
                    identifier: UUID().uuidString,
                    content: content,
                    trigger: trigger
                )

                try? await center.add(request)
            }
        }
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
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        hasNotification = true
        return [.badge, .sound, .list, .banner]
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        shouldShowNotification = true
    }
}
