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
    private let itemService: ItemService

    private(set) var hasNotification = false
    private(set) var shouldShowNotification = false

    private var center: UNUserNotificationCenter {
        UNUserNotificationCenter.current()
    }

    init(context: ModelContext) {
        itemService = .init(context: context)
        super.init()
        center.delegate = self
    }

    func register() async {
        _ = try? await center.requestAuthorization(
            options: [.badge, .sound, .alert, .carPlay]
        )
        center.removeAllPendingNotificationRequests()

        let requests = (try? buildUpcomingPaymentReminders()) ?? .empty

        for request in requests {
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
    func buildUpcomingPaymentReminders() throws -> [UNNotificationRequest] {
        let settings = AppStorage(.notificationSettings).wrappedValue as NotificationSettings

        guard settings.isEnabled else {
            return .empty
        }

        let items = try itemService.items(
            .items(.outgoIsGreaterThanOrEqualTo(amount: settings.thresholdAmount, onOrAfter: .now))
        )

        return items.compactMap { item in
            guard let scheduledDate = Calendar.current.date(byAdding: .day, value: -settings.daysBeforeDueDate, to: item.date),
                  let notificationDate = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: scheduledDate),
                  notificationDate > .now else {
                return nil
            }

            let content = UNMutableNotificationContent()
            content.title = "Upcoming Payment"
            content.body = "You have a payment of \(item.outgo) on \(item.date.formatted(.dateTime.month().day()))."
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
