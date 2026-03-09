//
//  NotificationService.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2024/05/31.
//

@preconcurrency import MHDeepLinking
@preconcurrency import MHNotificationPayloads
import SwiftData
import SwiftUI
import UserNotifications

@Observable
final class NotificationService: NSObject {
    private enum NotificationCategoryIdentifier {
        static let upcomingPaymentActions = "upcoming-payment.actions"
    }

    private enum NotificationActionIdentifier {
        static let viewItem = "upcoming-payment.view-item"
        static let viewMonth = NotificationRoutePayload.viewMonthActionIdentifier
    }

    enum AuthorizationState {
        case notDetermined
        case authorized
        case denied
    }

    private let modelContainer: ModelContainer
    let routeDestination: any MHDeepLinkURLDestination

    private(set) var hasNotification = false
    private(set) var shouldShowNotification = false
    private(set) var authorizationState: AuthorizationState = .notDetermined

    init(
        modelContainer: ModelContainer,
        routeDestination: any MHDeepLinkURLDestination
    ) {
        self.modelContainer = modelContainer
        self.routeDestination = routeDestination
        super.init()
        UNUserNotificationCenter.current().delegate = self
        registerNotificationCategories()
    }

    func register() async {
        let center = UNUserNotificationCenter.current()
        let requests = buildUpcomingPaymentReminders()
        let matcher = MHNotificationIdentifierMatcher(
            prefixes: [
                UpcomingPaymentNotificationPresentation.requestIdentifierPrefix,
                UpcomingPaymentNotificationPresentation.previewRequestIdentifierPrefix
            ]
        )

        let status = await MHNotificationOrchestrator.requestAuthorizationIfNeeded(
            center: center,
            options: [.badge, .sound, .alert, .carPlay, .providesAppNotificationSettings]
        )
        authorizationState = .init(status: status)

        _ = await MHNotificationOrchestrator.replaceManagedPendingRequests(
            center: center,
            requests: requests,
            matcher: matcher
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
    }

    func refreshAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationState = .init(status: settings.authorizationStatus)
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
            await deliverNotificationRoute(from: response)
        }
    }

    func userNotificationCenter(_: UNUserNotificationCenter,
                                openSettingsFor _: UNNotification?) {
        Task {
            notificationLogger.info("notification settings route requested")
            await routeDestination.setPendingURL(
                IncomesDeepLinkURLBuilder.preferredURL(for: .settings)
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
        NotificationRoutePayload.userInfo(for: presentation)
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
