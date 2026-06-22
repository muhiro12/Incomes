import Foundation

/// Builds universal-link deep link URLs used by external entry points.
public enum IncomesDeepLinkURLBuilder {
    /// Returns the universal-link URL for `route`.
    nonisolated public static func routeURL(for route: IncomesRoute) -> URL? {
        IncomesRouteURLBuilder.universalLinkURL(for: route)
    }

    /// Returns the preferred deep link for `route`, falling back to home when needed.
    nonisolated public static func preferredURL(for route: IncomesRoute) -> URL {
        if let preferredURL = IncomesRouteURLBuilder.universalLinkURL(for: route) {
            return preferredURL
        }
        if let customSchemeURL = IncomesRouteURLBuilder.customSchemeURL(for: route) {
            return customSchemeURL
        }
        if let homeURL = IncomesRouteURLBuilder.universalLinkURL(for: .home) {
            return homeURL
        }
        guard let fallbackURL = URL(
            string: "\(IncomesRouteURLDefaults.customScheme)://home"
        ) else {
            preconditionFailure("Failed to build fallback custom scheme URL.")
        }
        return fallbackURL
    }

    /// Returns the universal-link URL for the home route.
    nonisolated public static func homeURL() -> URL? {
        routeURL(for: .home)
    }

    /// Returns the preferred deep link for the home route.
    nonisolated public static func preferredHomeURL() -> URL {
        preferredURL(for: .home)
    }

    /// Returns the universal-link URL for the month containing `date`.
    nonisolated public static func monthURL(
        for date: Date,
        calendar: Calendar = .current
    ) -> URL? {
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        return routeURL(for: .month(year: year, month: month))
    }

    /// Returns the universal-link URL for the item identified by `itemID`.
    nonisolated public static func itemURL(
        for itemID: String
    ) -> URL? {
        routeURL(for: .item(itemID))
    }

    /// Returns the preferred deep link for the item identified by `itemID`.
    nonisolated public static func preferredItemURL(
        for itemID: String
    ) -> URL {
        preferredURL(for: .item(itemID))
    }

    /// Returns the preferred deep link for the month containing `date`.
    nonisolated public static func preferredMonthURL(
        for date: Date,
        calendar: Calendar = .current
    ) -> URL {
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        return preferredURL(for: .month(year: year, month: month))
    }
}
