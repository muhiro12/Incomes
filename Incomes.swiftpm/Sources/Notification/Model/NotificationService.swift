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

    // TODO: Delete after 2024/09
    private let year = 2_024
    private let months = [6, 7, 8]
    private let days = [10, 20, 30]
    private let hour = 20

    private var center: UNUserNotificationCenter {
        UNUserNotificationCenter.current()
    }

    override init() {
        super.init()
        center.delegate = self
    }

    func register() async {
        _ = try? await center.requestAuthorization(
            options: [.badge, .sound, .alert, .carPlay]
        )

        center.removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.title = .init(localized: "Important Subscription Update")
        content.body = .init(localized: "Starting August 1st, iCloud synchronization will be moved to the subscription plan. We appreciate your understanding and support.")
        content.badge = 1
        content.sound = .default

        for month in months {
            for day in days {
                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: .init(year: year, month: month, day: day, hour: hour),
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
