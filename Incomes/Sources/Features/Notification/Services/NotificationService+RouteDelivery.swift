//
//  NotificationService+RouteDelivery.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2026/03/07.
//

import Foundation
import MHPlatform
import UserNotifications

extension NotificationService {
    var notificationLogger: MHLogger {
        routeLogger
    }

    func deliverNotificationRoute(
        from response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        let payload = NotificationRoutePayload.codec.decode(userInfo)
        let responseContext = MHNotificationResponseContext(
            actionIdentifier: response.actionIdentifier
        )
        let legacyFallbackRouteURL = NotificationRoutePayload.legacyFallbackRouteURL(
            userInfo: userInfo,
            actionIdentifier: responseContext.actionIdentifier
        )
        let deliveredOutcome = await MHNotificationOrchestrator.deliverRouteURL(
            payload: payload,
            response: responseContext,
            destination: routeDestination,
            clearPendingURLWhenNoRoute: true
        ) { _, _ in
            legacyFallbackRouteURL
        }

        switch deliveredOutcome.source {
        case .payload:
            notificationLogger.info(
                "notification_route.resolved",
                metadata: IncomesLogging.metadata(
                    ("route_source", "payload")
                )
            )
        case .fallback:
            notificationLogger.warning(
                "notification_route.resolved",
                metadata: IncomesLogging.metadata(
                    ("route_source", "legacy_fallback")
                )
            )
        case .noRoute:
            notificationLogger.info(
                "notification_route.no_route",
                metadata: IncomesLogging.metadata(
                    ("route_source", "none")
                )
            )
        }
    }
}
