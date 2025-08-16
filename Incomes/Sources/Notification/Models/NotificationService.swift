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

@Observable
final class NotificationService: NSObject {
    private let modelContainer: ModelContainer

    private(set) var hasNotification = false
    private(set) var shouldShowNotification = false

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func register() async {
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(
            options: [.badge, .sound, .alert, .carPlay]
        )
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        for request in buildUpcomingPaymentReminders() {
            Task { @MainActor in
                try? await UNUserNotificationCenter.current().add(request)
            }
        }
    }

    func update() async {
        hasNotification = await UNUserNotificationCenter.current().deliveredNotifications().isNotEmpty
    }

    func refresh() {
        UNUserNotificationCenter.current().setBadgeCount(0)
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        hasNotification = false
        shouldShowNotification = false
    }

    func sendTestNotification() {
        guard let item = try? ItemService.nextItem(
            context: modelContainer.mainContext,
            date: .now
        ) else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = String(localized: "Upcoming Payment")
        content.body = String(
            localized: "\(item.content) - A payment of \(item.outgo.asCurrency) is due on \(item.localDate.formatted(.dateTime.weekday().month().day()))."
        )
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(
            identifier: "test-notification",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
}

nonisolated extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter,
                                willPresent _: UNNotification) async -> UNNotificationPresentationOptions { // swiftlint:disable:this async_without_await
        Task { @MainActor in
            hasNotification = true
        }
        return [.badge, .sound, .list, .banner]
    }

    func userNotificationCenter(_: UNUserNotificationCenter,
                                didReceive _: UNNotificationResponse) async { // swiftlint:disable:this async_without_await
        Task { @MainActor in
            shouldShowNotification = true
        }
    }
}

private extension NotificationService {
    func buildUpcomingPaymentReminders() -> [UNNotificationRequest] {
        let settings = AppStorage(.notificationSettings).wrappedValue
        guard let plans = try? UpcomingPaymentPlanner.build(
            context: modelContainer.mainContext,
            settings: settings,
            now: .now,
            limit: 20
        ) else {
            return .empty
        }

        return plans.map { plan in
            let item = plan.item
            let content = UNMutableNotificationContent()
            content.title = String(localized: "Upcoming Payment")
            content.body = String(
                localized: "\(item.content) - A payment of \(item.outgo.asCurrency) is due on \(item.localDate.formatted(.dateTime.weekday().month().day()))."
            )
            content.sound = .default

            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: plan.notifyDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

            return UNNotificationRequest(
                identifier: "payment-\(item.id)",
                content: content,
                trigger: trigger
            )
        }
    }
}
