//
//  NotificationService.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2024/05/31.
//

@preconcurrency import MHPlatform
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
        static let actionRouteURLs = "actionRouteURLs"
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

    private static let notificationPayloadCodec: MHNotificationPayloadCodec = .init(
        configuration: .init(
            keys: .init(
                defaultRouteURL: NotificationPayloadKey.primaryDeepLinkURL,
                fallbackRouteURL: NotificationPayloadKey.secondaryDeepLinkURL,
                actionRouteURLs: NotificationPayloadKey.actionRouteURLs
            ),
            decodableMetadataKeys: [
                NotificationPayloadKey.itemIdentifier,
                NotificationPayloadKey.notificationKind
            ]
        )
    )
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
        let requests = buildUpcomingPaymentReminders()
        let isManagedIdentifier: @Sendable (String) -> Bool = { identifier in
            identifier.hasPrefix(UpcomingPaymentNotificationPresentation.requestIdentifierPrefix)
                || identifier.hasPrefix(
                    UpcomingPaymentNotificationPresentation.previewRequestIdentifierPrefix
                )
        }

        let status = await MHNotificationOrchestrator.requestAuthorizationIfNeeded(
            center: center,
            options: [.badge, .sound, .alert, .carPlay, .providesAppNotificationSettings]
        )
        authorizationState = .init(status: status)

        _ = await MHNotificationOrchestrator.replaceManagedPendingRequests(
            center: center,
            requests: requests,
            isManagedIdentifier: isManagedIdentifier
        )
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
            pendingDeepLinkURL = resolveDeepLinkURL(from: response)
        }
    }

    func userNotificationCenter(_: UNUserNotificationCenter,
                                openSettingsFor _: UNNotification?) {
        Task {
            notificationLogger.info("notification settings route requested")
            pendingDeepLinkURL = IncomesDeepLinkURLBuilder.preferredURL(for: .settings)
        }
    }
}

private extension NotificationService {
    var notificationLogger: MHLogger {
        IncomesApp.logger(
            category: "NotificationRoute",
            source: #fileID
        )
    }

    func registerNotificationCategories() {
        MHNotificationOrchestrator.registerCategories(
            [
                .init(
                    identifier: NotificationCategoryIdentifier.upcomingPaymentActions,
                    actions: [
                        .init(
                            identifier: NotificationActionIdentifier.viewItem,
                            title: String(localized: "View Item")
                        ),
                        .init(
                            identifier: NotificationActionIdentifier.viewMonth,
                            title: String(localized: "View Month")
                        )
                    ]
                )
            ],
            center: UNUserNotificationCenter.current()
        )
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
        Self.notificationPayloadCodec.encode(
            .init(
                routes: .init(
                    defaultRouteURL: presentation.primaryRouteURL,
                    fallbackRouteURL: presentation.secondaryRouteURL,
                    actionRouteURLs: [
                        NotificationActionIdentifier.viewMonth: presentation.secondaryRouteURL
                    ]
                ),
                metadata: [
                    NotificationPayloadKey.itemIdentifier: presentation.targetContentIdentifier,
                    NotificationPayloadKey.notificationKind: NotificationKind.upcomingPayment
                ]
            )
        )
    }

    func resolveDeepLinkURL(
        from response: UNNotificationResponse
    ) -> URL? {
        let userInfo = response.notification.request.content.userInfo

        if response.actionIdentifier == NotificationActionIdentifier.viewMonth,
           userInfo[NotificationPayloadKey.actionRouteURLs] == nil,
           let monthURL = extractLegacyDeepLinkURL(
            from: userInfo,
            key: NotificationPayloadKey.secondaryDeepLinkURL
           ) {
            notificationLogger.notice("notification route resolved via legacy month fallback")
            return monthURL
        }

        let routeURL = MHNotificationOrchestrator.resolveRouteURL(
            userInfo: userInfo,
            actionIdentifier: response.actionIdentifier,
            codec: Self.notificationPayloadCodec
        )
        if routeURL == nil {
            notificationLogger.info("notification route resolution returned no route")
        } else {
            notificationLogger.info("notification route resolved")
        }
        return routeURL
    }

    func extractLegacyDeepLinkURL(
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
