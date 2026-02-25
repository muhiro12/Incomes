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
    private enum NotificationPayloadKey {
        static let deepLinkURL = "deepLinkURL"
    }

    private let modelContainer: ModelContainer

    private(set) var hasNotification = false
    private(set) var shouldShowNotification = false
    private(set) var pendingDeepLinkURL: URL?

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
            Task {
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
        pendingDeepLinkURL = nil
    }

    func consumePendingDeepLinkURL() -> URL? {
        let deepLinkURL = pendingDeepLinkURL
        pendingDeepLinkURL = nil
        return deepLinkURL
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
        if let deepLinkUserInfo = buildDeepLinkUserInfo(for: item) {
            content.userInfo = deepLinkUserInfo
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(
            identifier: "test-notification",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
}

extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter,
                                willPresent _: UNNotification) async -> UNNotificationPresentationOptions { // swiftlint:disable:this async_without_await
        Task {
            hasNotification = true
        }
        return [.badge, .sound, .list, .banner]
    }

    func userNotificationCenter(_: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async { // swiftlint:disable:this async_without_await
        Task {
            shouldShowNotification = true
            pendingDeepLinkURL = extractDeepLinkURL(
                from: response.notification.request.content.userInfo
            )
        }
    }
}

private extension NotificationService {
    func buildDeepLinkUserInfo(for item: Item) -> [AnyHashable: Any]? {
        guard let deepLinkURL = buildDeepLinkURL(for: item) else {
            return nil
        }
        return [
            NotificationPayloadKey.deepLinkURL: deepLinkURL.absoluteString
        ]
    }

    func buildDeepLinkURL(for item: Item) -> URL? {
        IncomesDeepLinkURLBuilder.monthURL(for: item.localDate)
    }

    func extractDeepLinkURL(from userInfo: [AnyHashable: Any]) -> URL? {
        if let deepLinkURLString = userInfo[NotificationPayloadKey.deepLinkURL] as? String {
            return URL(string: deepLinkURLString)
        }
        if let deepLinkURL = userInfo[NotificationPayloadKey.deepLinkURL] as? URL {
            return deepLinkURL
        }
        return nil
    }

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
            if let deepLinkUserInfo = buildDeepLinkUserInfo(for: item) {
                content.userInfo = deepLinkUserInfo
            }

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
