import Foundation
import MHPlatformCore

/// Builds and decodes notification route payloads for upcoming payment reminders.
public enum NotificationRoutePayload {
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

    /// Notification action identifier for opening the reminder item.
    public static let viewItemActionIdentifier = "upcoming-payment.view-item"

    /// Notification action identifier for opening the reminder month.
    public static let viewMonthActionIdentifier = "upcoming-payment.view-month"

    /// Codec configured for Incomes notification route payload keys.
    public static let codec: MHNotificationPayloadCodec = .init(
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

    /// Builds `UNNotificationContent.userInfo` values from a presentation.
    public static func userInfo(
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

    /// Returns the legacy month route URL for old notification payloads.
    public static func legacyFallbackRouteURL(
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
