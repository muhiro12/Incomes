//
//  NotificationService+RouteDelivery.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2026/03/07.
//

import Foundation
@preconcurrency import MHLogging
@preconcurrency import MHNotificationPayloads
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
            deliver: deliverPendingRoute,
            clearPendingURLWhenNoRoute: true
        ) { _, _ in
            legacyFallbackRouteURL
        }

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
