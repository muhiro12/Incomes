//
//  NotificationService+RouteDelivery.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2026/03/07.
//

import Foundation
@preconcurrency import MHPlatform
import UserNotifications

extension NotificationService {
    var notificationLogger: MHLogger {
        IncomesApp.logger(
            category: "NotificationRoute",
            source: #fileID
        )
    }

    func deliverNotificationRoute(
        from response: UNNotificationResponse
    ) async {
        @MainActor
        @Sendable
        func deliverPendingDeepLink(_ deepLinkURL: URL?) async {
            await setPendingDeepLinkURL(deepLinkURL)
        }

        let userInfo = response.notification.request.content.userInfo
        let fallbackRouteURL = NotificationRoutePayload.legacyFallbackRouteURL(
            userInfo: userInfo,
            actionIdentifier: response.actionIdentifier
        )
        let outcome = MHNotificationOrchestrator.routeDeliveryOutcome(
            userInfo: userInfo,
            actionIdentifier: response.actionIdentifier,
            codec: NotificationRoutePayload.codec,
            ) { _, _ in
            fallbackRouteURL
        }
        let deliveredOutcome = await MHNotificationOrchestrator.deliverRouteURL(
            outcome,
            deliver: deliverPendingDeepLink,
            clearPendingURLWhenNoRoute: true
        )

        switch deliveredOutcome.source {
        case .payload:
            notificationLogger.info("notification route resolved")
        case .fallback:
            notificationLogger.notice("notification route resolved via legacy month fallback")
        case .noRoute:
            notificationLogger.info("notification route resolution returned no route")
        }
    }
}
