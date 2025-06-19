//
//  NotificationService.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2024/05/31.
//  Copyright © 2024 Hiromu Nakano. All rights reserved.
//

import SwiftData
import SwiftUI
import UserNotifications

@MainActor
@Observable
final class NotificationService: NSObject {
    private let modelContainer: ModelContainer

    private(set) var hasNotification = false
    private(set) var shouldShowNotification = false

    private var center: UNUserNotificationCenter {
        UNUserNotificationCenter.current()
    }

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        super.init()
        center.delegate = self
    }

    func register() async {
        _ = try? await center.requestAuthorization(
            options: [.badge, .sound, .alert, .carPlay]
        )
        center.removeAllPendingNotificationRequests()
        for request in buildUpcomingPaymentReminders() {
            try? await center.add(request)
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

    func sendTestNotification() {
        guard let item = try? GetNextItemIntent.perform((context: modelContainer.mainContext, date: .now)) else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = String(localized: "Upcoming Payment")
        content.body = String(
            localized: "\(item.content) - A payment of \(item.outgo.asCurrency) is due on \(item.date.formatted(.dateTime.weekday().month().day()))."
        )
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(
            identifier: "test-notification",
            content: content,
            trigger: trigger
        )

        center.add(request)
    }
}

extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter,
                                willPresent _: UNNotification) async -> UNNotificationPresentationOptions { // swiftlint:disable:this async_without_await
        hasNotification = true
        return [.badge, .sound, .list, .banner]
    }

    func userNotificationCenter(_: UNUserNotificationCenter,
                                didReceive _: UNNotificationResponse) async { // swiftlint:disable:this async_without_await
        shouldShowNotification = true
    }
}

private extension NotificationService {
    func buildUpcomingPaymentReminders() -> [UNNotificationRequest] {
        let settings = AppStorage(.notificationSettings).wrappedValue

        guard settings.isEnabled else {
            return .empty
        }

        var descriptor = FetchDescriptor.items(
            .outgoIsGreaterThanOrEqualTo(amount: settings.thresholdAmount, onOrAfter: .now),
            order: .forward
        )
        descriptor.fetchLimit = 20

        guard let items = try? modelContainer.mainContext.fetch(descriptor) else {
            return .empty
        }

        return items.compactMap { item in
            guard let scheduledDate = Calendar.current.date(
                byAdding: .day,
                value: -settings.daysBeforeDueDate,
                to: item.localDate
            ) else {
                return nil
            }

            let notifyTime = Calendar.current.dateComponents(
                [.hour, .minute],
                from: settings.notifyTime
            )

            guard let notificationDate = Calendar.current.date(
                bySettingHour: notifyTime.hour ?? 20,
                minute: notifyTime.minute ?? 0,
                second: 0,
                of: scheduledDate
            ) else {
                return nil
            }

            guard notificationDate > .now else {
                return nil
            }

            let content = UNMutableNotificationContent()
            content.title = String(localized: "Upcoming Payment")
            content.body = String(
                localized: "\(item.content) - A payment of \(item.outgo.asCurrency) is due on \(item.localDate.formatted(.dateTime.weekday().month().day()))."
            )
            content.sound = .default

            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

            return UNNotificationRequest(
                identifier: "payment-\(item.id)",
                content: content,
                trigger: trigger
            )
        }
    }
}
