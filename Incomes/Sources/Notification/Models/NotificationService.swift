//
//  NotificationService.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2024/05/31.
//

import SwiftData
import SwiftUI
import UserNotifications

@Observable
final class NotificationService: NSObject {
    private enum NotificationPayloadKey {
        static let itemIdentifier = "itemIdentifier"
        static let notificationKind = "notificationKind"
        static let primaryDeepLinkURL = "primaryDeepLinkURL"
        static let secondaryDeepLinkURL = "secondaryDeepLinkURL"
    }

    private enum NotificationCategoryIdentifier {
        static let upcomingPaymentActions = "upcoming-payment.actions"
    }

    private enum NotificationActionIdentifier {
        static let viewItem = "upcoming-payment.view-item"
        static let viewMonth = "upcoming-payment.view-month"
    }

    private enum NotificationKind {
        static let upcomingPayment = "upcoming-payment"
    }

    enum AuthorizationState {
        case notDetermined
        case authorized
        case denied
    }

    private let modelContainer: ModelContainer

    private(set) var hasNotification = false
    private(set) var shouldShowNotification = false
    private(set) var pendingDeepLinkURL: URL?
    private(set) var authorizationState: AuthorizationState = .notDetermined

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        super.init()
        UNUserNotificationCenter.current().delegate = self
        registerNotificationCategories()
    }

    func register() async {
        let center = UNUserNotificationCenter.current()

        _ = try? await center.requestAuthorization(
            options: [.badge, .sound, .alert, .carPlay, .providesAppNotificationSettings]
        )

        await refreshAuthorizationStatus()

        let pendingIdentifiers = await pendingNotificationIdentifiers()
        if pendingIdentifiers.isNotEmpty {
            center.removePendingNotificationRequests(withIdentifiers: pendingIdentifiers)
        }

        for request in buildUpcomingPaymentReminders() {
            try? await center.add(request)
        }
    }

    func update() async {
        await refreshAuthorizationStatus()
        hasNotification = await deliveredNotificationIdentifiers().isNotEmpty
    }

    func refresh() async {
        let center = UNUserNotificationCenter.current()
        try? await center.setBadgeCount(0)

        let deliveredIdentifiers = await deliveredNotificationIdentifiers()
        if deliveredIdentifiers.isNotEmpty {
            center.removeDeliveredNotifications(
                withIdentifiers: deliveredIdentifiers
            )
        }

        hasNotification = false
        shouldShowNotification = false
        pendingDeepLinkURL = nil
    }

    func refreshAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationState = .init(status: settings.authorizationStatus)
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

        let settings = AppStorage(.notificationSettings).wrappedValue
        let plan = UpcomingPaymentPlanner.PlannedPayment(
            item: item,
            notifyDate: Date.now.addingTimeInterval(1)
        )
        guard let presentation = UpcomingPaymentNotificationPresentationBuilder.build(
            plans: [plan],
            settings: settings,
            now: .now
        ).first?.previewPresentation() else { // swiftlint:disable:this multiline_function_chains
            return
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = buildNotificationRequest(
            presentation: presentation,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
}

extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter,
                                willPresent _: UNNotification) async -> UNNotificationPresentationOptions { // swiftlint:disable:this async_without_await line_length
        Task {
            hasNotification = true
        }
        return [.badge, .sound, .list, .banner]
    }

    func userNotificationCenter(_: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async { // swiftlint:disable:this async_without_await line_length
        Task {
            shouldShowNotification = true
            pendingDeepLinkURL = extractDeepLinkURL(from: response)
        }
    }

    func userNotificationCenter(_: UNUserNotificationCenter,
                                openSettingsFor _: UNNotification?) {
        Task {
            pendingDeepLinkURL = IncomesDeepLinkURLBuilder.preferredURL(for: .settings)
        }
    }
}

private extension NotificationService {
    func registerNotificationCategories() {
        let categories: Set<UNNotificationCategory> = [
            .init(
                identifier: NotificationCategoryIdentifier.upcomingPaymentActions,
                actions: [
                    .init(
                        identifier: NotificationActionIdentifier.viewItem,
                        title: String(localized: "View Item"),
                        options: [.foreground]
                    ),
                    .init(
                        identifier: NotificationActionIdentifier.viewMonth,
                        title: String(localized: "View Month"),
                        options: [.foreground]
                    )
                ],
                intentIdentifiers: [],
                options: []
            )
        ]

        UNUserNotificationCenter.current().setNotificationCategories(categories)
    }

    func buildNotificationRequest(
        presentation: UpcomingPaymentNotificationPresentation,
        trigger: UNNotificationTrigger
    ) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = presentation.itemContent
        content.subtitle = "\(presentation.amount.asCurrency) • \(relativeDueText(for: presentation.daysUntilDue))"
        content.body = String(
            localized: "Due on \(presentation.dueDate.formatted(.dateTime.weekday().month().day()))"
        )
        content.sound = .default
        content.categoryIdentifier = NotificationCategoryIdentifier.upcomingPaymentActions
        content.threadIdentifier = presentation.threadIdentifier
        content.targetContentIdentifier = presentation.targetContentIdentifier
        content.relevanceScore = presentation.relevanceScore
        content.interruptionLevel = notificationInterruptionLevel(
            from: presentation.interruptionLevel
        )
        content.badge = .init(value: presentation.badgeCount)
        content.userInfo = buildUserInfo(for: presentation)

        return .init(
            identifier: presentation.requestIdentifier,
            content: content,
            trigger: trigger
        )
    }

    func buildUserInfo(
        for presentation: UpcomingPaymentNotificationPresentation
    ) -> [AnyHashable: Any] {
        [
            NotificationPayloadKey.itemIdentifier: presentation.targetContentIdentifier,
            NotificationPayloadKey.notificationKind: NotificationKind.upcomingPayment,
            NotificationPayloadKey.primaryDeepLinkURL: presentation.primaryRouteURL.absoluteString,
            NotificationPayloadKey.secondaryDeepLinkURL: presentation.secondaryRouteURL.absoluteString
        ]
    }

    func extractDeepLinkURL(
        from response: UNNotificationResponse
    ) -> URL? {
        let userInfo = response.notification.request.content.userInfo

        if response.actionIdentifier == NotificationActionIdentifier.viewMonth,
           let monthURL = extractDeepLinkURL(
            from: userInfo,
            key: NotificationPayloadKey.secondaryDeepLinkURL
           ) {
            return monthURL
        }

        if let primaryURL = extractDeepLinkURL(
            from: userInfo,
            key: NotificationPayloadKey.primaryDeepLinkURL
        ) {
            return primaryURL
        }

        return extractDeepLinkURL(
            from: userInfo,
            key: NotificationPayloadKey.secondaryDeepLinkURL
        )
    }

    func extractDeepLinkURL(
        from userInfo: [AnyHashable: Any],
        key: String
    ) -> URL? {
        if let deepLinkURLString = userInfo[key] as? String {
            return URL(string: deepLinkURLString)
        }
        if let deepLinkURL = userInfo[key] as? URL {
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
            limit: 20 // swiftlint:disable:this no_magic_numbers
        ) else {
            return .empty
        }

        let presentations = UpcomingPaymentNotificationPresentationBuilder.build(
            plans: plans,
            settings: settings,
            now: .now
        )

        return presentations.map { presentation in
            let triggerDate = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: presentation.notifyDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

            return buildNotificationRequest(
                presentation: presentation,
                trigger: trigger
            )
        }
    }

    func relativeDueText(for daysUntilDue: Int) -> String {
        switch daysUntilDue {
        case ...0:
            return String(localized: "Due today")
        case 1:
            return String(localized: "Due tomorrow")
        default:
            return String(localized: "Due in \(daysUntilDue) days")
        }
    }

    func notificationInterruptionLevel(
        from interruptionLevel: UpcomingPaymentNotificationPresentation.InterruptionLevel
    ) -> UNNotificationInterruptionLevel {
        switch interruptionLevel {
        case .active:
            return .active
        }
    }

    func pendingNotificationIdentifiers() async -> [String] {
        await UNUserNotificationCenter.current().pendingNotificationRequests() // swiftlint:disable:this line_length multiline_function_chains
            .map(\.identifier)
            .filter(isManagedNotificationIdentifier)
    }

    func deliveredNotificationIdentifiers() async -> [String] {
        await UNUserNotificationCenter.current().deliveredNotifications() // swiftlint:disable:this line_length multiline_function_chains
            .map(\.request.identifier)
            .filter(isManagedNotificationIdentifier)
    }

    func isManagedNotificationIdentifier(_ identifier: String) -> Bool {
        identifier.hasPrefix(UpcomingPaymentNotificationPresentation.requestIdentifierPrefix) ||
            identifier.hasPrefix(UpcomingPaymentNotificationPresentation.previewRequestIdentifierPrefix)
    }
}

private extension NotificationService.AuthorizationState {
    init(status: UNAuthorizationStatus) {
        switch status {
        case .authorized,
             .ephemeral,
             .provisional:
            self = .authorized
        case .denied:
            self = .denied
        case .notDetermined:
            self = .notDetermined
        @unknown default:
            self = .denied
        }
    }
}
