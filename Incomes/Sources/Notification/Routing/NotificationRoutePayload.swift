import Foundation

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

    static func userInfo(
        for presentation: UpcomingPaymentNotificationPresentation
    ) -> [AnyHashable: Any] {
        [
            Key.itemIdentifier: presentation.targetContentIdentifier,
            Key.notificationKind: NotificationKind.upcomingPayment,
            Key.primaryDeepLinkURL: presentation.primaryRouteURL.absoluteString,
            Key.secondaryDeepLinkURL: presentation.secondaryRouteURL.absoluteString,
            Key.actionRouteURLs: [
                viewMonthActionIdentifier: presentation.secondaryRouteURL.absoluteString
            ]
        ]
    }

    static func deepLinkURL(
        userInfo: [AnyHashable: Any],
        actionIdentifier: String
    ) -> URL? {
        if let actionRouteURL = actionRouteURL(
            userInfo: userInfo,
            actionIdentifier: actionIdentifier
        ) {
            return actionRouteURL
        }

        if let primaryURL = deepLinkURL(
            from: userInfo,
            key: Key.primaryDeepLinkURL
        ) {
            return primaryURL
        }

        if let legacyFallbackRouteURL = legacyFallbackRouteURL(
            userInfo: userInfo,
            actionIdentifier: actionIdentifier
        ) {
            return legacyFallbackRouteURL
        }

        return deepLinkURL(
            from: userInfo,
            key: Key.secondaryDeepLinkURL
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

        return deepLinkURL(
            from: userInfo,
            key: Key.secondaryDeepLinkURL
        )
    }
}

private extension NotificationRoutePayload {
    static func actionRouteURL(
        userInfo: [AnyHashable: Any],
        actionIdentifier: String
    ) -> URL? {
        if let actionRouteURLs = userInfo[Key.actionRouteURLs] as? [String: Any],
           let value = actionRouteURLs[actionIdentifier] {
            return deepLinkURL(from: value)
        }

        if let actionRouteURLs = userInfo[Key.actionRouteURLs] as? [AnyHashable: Any],
           let value = actionRouteURLs[actionIdentifier] {
            return deepLinkURL(from: value)
        }

        return nil
    }

    static func deepLinkURL(
        from userInfo: [AnyHashable: Any],
        key: String
    ) -> URL? {
        guard let value = userInfo[key] else {
            return nil
        }
        return deepLinkURL(from: value)
    }

    static func deepLinkURL(from value: Any) -> URL? {
        if let deepLinkURLString = value as? String {
            return URL(string: deepLinkURLString)
        }

        if let deepLinkURL = value as? URL {
            return deepLinkURL
        }

        return nil
    }
}
