//
//  NotificationService.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2024/05/31.
//

import MHPlatform
import SwiftData
import SwiftUI
import UserNotifications

@Observable
final class NotificationService: NSObject {
    private enum NotificationCategoryIdentifier {
        static let upcomingPaymentActions = "upcoming-payment.actions"
    }

    enum AuthorizationState {
        case notDetermined
        case authorized
        case denied
    }

    private let modelContainer: ModelContainer
    private let logger: MHLogger
    let routeLogger: MHLogger
    let routeDestination: any MHDeepLinkURLDestination

    private(set) var hasNotification = false
    private(set) var shouldShowNotification = false
    private(set) var authorizationState: AuthorizationState = .notDetermined

    init(
        modelContainer: ModelContainer,
        routeDestination: any MHDeepLinkURLDestination,
        logging: MHLoggingBootstrap
    ) {
        self.modelContainer = modelContainer
        logger = IncomesLogging.logger(
            logging: logging,
            category: IncomesLogging.Category.notification,
            source: #fileID
        )
        routeLogger = IncomesLogging.logger(
            logging: logging,
            category: IncomesLogging.Category.notificationRoute,
            source: #fileID
        )
        self.routeDestination = routeDestination
        super.init()
        UNUserNotificationCenter.current().delegate = self
        registerNotificationCategories()
    }

    func register() async {
        let center = UNUserNotificationCenter.current()
        let requests = buildUpcomingPaymentReminders()
        let matcher = MHNotificationIdentifierMatcher(
            prefixes: UpcomingPaymentNotificationPresentation.managedRequestIdentifierPrefixes
        )
        logger.info(
            "notification.register_requested",
            metadata: IncomesLogging.metadata(
                ("request_count", IncomesLogging.count(requests.count))
            )
        )

        let status = await MHNotificationOrchestrator.requestAuthorizationIfNeeded(
            center: center,
            options: [.badge, .sound, .alert, .carPlay, .providesAppNotificationSettings]
        )
        authorizationState = .init(status: status)
        logger.notice(
            "notification.authorization_updated",
            metadata: IncomesLogging.metadata(
                ("authorization_status", authorizationState.logValue)
            )
        )

        _ = await MHNotificationOrchestrator.replaceManagedPendingRequests(
            center: center,
            requests: requests,
            matcher: matcher
        )
        logger.notice(
            "notification.schedule_replaced",
            metadata: IncomesLogging.metadata(
                ("request_count", IncomesLogging.count(requests.count))
            )
        )
    }

    func update() async {
        await refreshAuthorizationStatus()
        let deliveredIdentifiers = await deliveredNotificationIdentifiers()
        hasNotification = !deliveredIdentifiers.isEmpty
        logger.info(
            "notification.state_updated",
            metadata: IncomesLogging.metadata(
                ("authorization_status", authorizationState.logValue),
                ("has_notification", IncomesLogging.bool(hasNotification))
            )
        )
    }

    func refresh() async {
        let center = UNUserNotificationCenter.current()
        try? await center.setBadgeCount(0)

        let deliveredIdentifiers = await deliveredNotificationIdentifiers()
        if !deliveredIdentifiers.isEmpty {
            center.removeDeliveredNotifications(
                withIdentifiers: deliveredIdentifiers
            )
        }

        hasNotification = false
        shouldShowNotification = false
        logger.notice(
            "notification.delivered_cleared",
            metadata: IncomesLogging.metadata(
                ("cleared_count", IncomesLogging.count(deliveredIdentifiers.count))
            )
        )
    }

    func refreshAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationState = .init(status: settings.authorizationStatus)
        logger.info(
            "notification.authorization_refreshed",
            metadata: IncomesLogging.metadata(
                ("authorization_status", authorizationState.logValue)
            )
        )
    }

    func sendTestNotification() {
        let now = Date.now
        let triggerInterval: TimeInterval = 1
        let settings = currentNotificationSettings()
        let result: UpcomingPaymentTestNoticeResult
        do {
            result = try UpcomingPaymentOperations.testNotificationPresentation(
                context: modelContainer.mainContext,
                settings: settings,
                now: now,
                notifyDate: now.addingTimeInterval(triggerInterval)
            )
        } catch {
            logger.warning(
                "notification.test_skipped",
                metadata: IncomesLogging.metadata(
                    ("failure_reason", "operation_failed")
                )
            )
            return
        }

        guard case .presentation(let presentation) = result else {
            logSkippedTestNotification(result)
            return
        }

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: triggerInterval,
            repeats: false
        )
        let request = buildNotificationRequest(
            presentation: presentation,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
        logger.notice(
            "notification.test_scheduled",
            metadata: IncomesLogging.metadata(
                ("request_identifier_present", "true")
            )
        )
    }
}

private extension NotificationService {
    func logSkippedTestNotification(
        _ result: UpcomingPaymentTestNoticeResult
    ) {
        guard case .unavailable(let reason) = result else {
            return
        }

        logger.warning(
            "notification.test_skipped",
            metadata: IncomesLogging.metadata(
                ("failure_reason", reason.rawValue)
            )
        )
    }
}

extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter,
                                willPresent _: UNNotification) async -> UNNotificationPresentationOptions { // swiftlint:disable:this async_without_await line_length
        Task {
            hasNotification = true
            logger.info("notification.will_present")
        }
        return [.badge, .sound, .list, .banner]
    }

    func userNotificationCenter(_: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async { // swiftlint:disable:this async_without_await line_length
        Task {
            shouldShowNotification = true
            logger.notice(
                "notification.response_received",
                metadata: IncomesLogging.metadata(
                    ("action_identifier", response.actionIdentifier),
                    ("managed_identifier", IncomesLogging.bool(
                        UpcomingPaymentNotificationPresentation.isManagedRequestIdentifier(
                            response.notification.request.identifier
                        )
                    ))
                )
            )
            await deliverNotificationRoute(from: response)
        }
    }

    func userNotificationCenter(_: UNUserNotificationCenter,
                                openSettingsFor _: UNNotification?) {
        Task {
            logger.info("notification.settings_route_requested")
            await routeDestination.setPendingURL(
                MainNavigationOperations.preferredURL(for: .settings)
            )
        }
    }
}

private extension NotificationService {
    func registerNotificationCategories() {
        MHNotificationOrchestrator.registerCategories(
            [
                .init(
                    identifier: NotificationCategoryIdentifier.upcomingPaymentActions,
                    actions: [
                        .init(
                            identifier: NotificationRoutePayload.viewItemActionIdentifier,
                            title: String(localized: "View Item")
                        ),
                        .init(
                            identifier: NotificationRoutePayload.viewMonthActionIdentifier,
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
        NotificationRoutePayload.userInfo(for: presentation)
    }

    func buildUpcomingPaymentReminders() -> [UNNotificationRequest] {
        let settings = currentNotificationSettings()
        guard let plans = try? UpcomingPaymentOperations.build(
            context: modelContainer.mainContext,
            settings: settings,
            now: .now,
            limit: 20 // swiftlint:disable:this no_magic_numbers
        ) else {
            return []
        }

        let presentations = UpcomingPaymentOperations.notificationPresentations(
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

    func currentNotificationSettings() -> NotificationSettings {
        let preferenceStore = MHPreferenceStore()

        guard let rawValue = preferenceStore.string(for: \.notificationSettings),
              let settings = NotificationSettings(rawValue: rawValue) else {
            return .init()
        }

        return settings
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
            .filter(UpcomingPaymentNotificationPresentation.isManagedRequestIdentifier)
    }
}

private extension NotificationService.AuthorizationState {
    var logValue: String {
        switch self {
        case .notDetermined:
            "not_determined"
        case .authorized:
            "authorized"
        case .denied:
            "denied"
        }
    }

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
