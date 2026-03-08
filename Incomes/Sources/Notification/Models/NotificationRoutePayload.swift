import Foundation
@preconcurrency import MHPlatform

enum NotificationRoutePayload {
    private enum Key {
        static let itemIdentifier = "itemIdentifier"
        static let notificationKind = "notificationKind"
        static let primaryDeepLinkURL = "primaryDeepLinkURL"
        static let secondaryDeepLinkURL = "secondaryDeepLinkURL"
        static let actionRouteURLs = "actionRouteURLs"
    }

    private enum NotificationKind {
        static let upcomingPayment = "upcoming-payment"
    }

    static let viewMonthActionIdentifier = "upcoming-payment.view-month"

    static let codec: MHNotificationPayloadCodec = .init(
        configuration: .init(
            keys: .init(
                defaultRouteURL: Key.primaryDeepLinkURL,
                fallbackRouteURL: Key.secondaryDeepLinkURL,
                actionRouteURLs: Key.actionRouteURLs
            ),
            decodableMetadataKeys: [
                Key.itemIdentifier,
                Key.notificationKind
            ]
        )
    )

    static func userInfo(
        for presentation: UpcomingPaymentNotificationPresentation
    ) -> [AnyHashable: Any] {
        codec.encode(
            .init(
                routes: .init(
                    defaultRouteURL: presentation.primaryRouteURL,
                    fallbackRouteURL: presentation.secondaryRouteURL,
                    actionRouteURLs: [
                        viewMonthActionIdentifier: presentation.secondaryRouteURL
                    ]
                ),
                metadata: [
                    Key.itemIdentifier: presentation.targetContentIdentifier,
                    Key.notificationKind: NotificationKind.upcomingPayment
                ]
            )
        )
    }

    static func legacyFallbackRouteURL(
        userInfo: [AnyHashable: Any],
        actionIdentifier: String
    ) -> URL? {
        guard actionIdentifier == viewMonthActionIdentifier,
              userInfo[Key.actionRouteURLs] == nil else {
            return nil
        }

        return legacyDeepLinkURL(
            from: userInfo,
            key: Key.secondaryDeepLinkURL
        )
    }

    private static func legacyDeepLinkURL(
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
}
