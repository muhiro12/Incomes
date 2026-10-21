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

    /// Notification action identifier for opening the reminder item.
    public static let viewItemActionIdentifier = UpcomingPaymentNotificationIdentifiers.viewItemActionIdentifier

    /// Notification action identifier for opening the reminder month.
    public static let viewMonthActionIdentifier = UpcomingPaymentNotificationIdentifiers.viewMonthActionIdentifier

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
                    Key.notificationKind: UpcomingPaymentNotificationIdentifiers.contentKind
                ]
            )
        )
    }
}
