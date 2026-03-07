//
//  NotificationService+RouteDelivery.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2026/03/07.
//

import Foundation
@preconcurrency import MHPlatform
import UserNotifications

private enum NotificationRouteDeliveryConstants {
    static let viewMonthActionIdentifier = "upcoming-payment.view-month"
    static let primaryDeepLinkURLKey = "primaryDeepLinkURL"
    static let secondaryDeepLinkURLKey = "secondaryDeepLinkURL"
    static let actionRouteURLsKey = "actionRouteURLs"
    static let itemIdentifierKey = "itemIdentifier"
    static let notificationKindKey = "notificationKind"

    static let payloadCodec: MHNotificationPayloadCodec = .init(
        configuration: .init(
            keys: .init(
                defaultRouteURL: primaryDeepLinkURLKey,
                fallbackRouteURL: secondaryDeepLinkURLKey,
                actionRouteURLs: actionRouteURLsKey
            ),
            decodableMetadataKeys: [
                itemIdentifierKey,
                notificationKindKey
            ]
        )
    )
}

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
        let payload = NotificationRouteDeliveryConstants.payloadCodec.decode(userInfo)
        let responseContext = MHNotificationResponseContext(
            actionIdentifier: response.actionIdentifier
        )
        let fallbackRouteURL = legacyMonthFallbackRouteURL(
            userInfo: userInfo,
            actionIdentifier: response.actionIdentifier
        )

        let outcome = await MHNotificationOrchestrator.deliverRouteURL(
            payload: payload,
            response: responseContext,
            deliver: deliverPendingDeepLink,
            clearPendingURLWhenNoRoute: true
        ) { _, _ in
            fallbackRouteURL
        }

        switch outcome.source {
        case .payload:
            notificationLogger.info("notification route resolved")
        case .fallback:
            notificationLogger.notice("notification route resolved via legacy month fallback")
        case .noRoute:
            notificationLogger.info("notification route resolution returned no route")
        }
    }
}

private extension NotificationService {
    func legacyDeepLinkURL(
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

    func legacyMonthFallbackRouteURL(
        userInfo: [AnyHashable: Any],
        actionIdentifier: String
    ) -> URL? {
        guard actionIdentifier == NotificationRouteDeliveryConstants.viewMonthActionIdentifier,
              userInfo[NotificationRouteDeliveryConstants.actionRouteURLsKey] == nil else {
            return nil
        }
        return legacyDeepLinkURL(
            from: userInfo,
            key: NotificationRouteDeliveryConstants.secondaryDeepLinkURLKey
        )
    }
}
