import Foundation

/// Builds universal-link deep link URLs used by external entry points.
public enum IncomesDeepLinkURLBuilder {
    /// Documented for SwiftLint compliance.
    public static func routeURL(for route: IncomesRoute) -> URL? {
        IncomesRouteURLBuilder.universalLinkURL(for: route)
    }

    /// Documented for SwiftLint compliance.
    public static func preferredURL(for route: IncomesRoute) -> URL {
        if let universalLinkURL = routeURL(for: route) {
            return universalLinkURL
        }
        if let customSchemeURL = IncomesRouteURLBuilder.customSchemeURL(for: route) {
            return customSchemeURL
        }
        if let homeCustomSchemeURL = IncomesRouteURLBuilder.customSchemeURL(for: .home) {
            return homeCustomSchemeURL
        }
        guard let fallbackURL = URL(
            string: "\(IncomesRouteURLDefaults.customScheme)://home"
        ) else {
            preconditionFailure("Failed to build fallback custom scheme URL.")
        }
        return fallbackURL
    }

    /// Documented for SwiftLint compliance.
    public static func homeURL() -> URL? {
        routeURL(for: .home)
    }

    /// Documented for SwiftLint compliance.
    public static func preferredHomeURL() -> URL {
        preferredURL(for: .home)
    }

    /// Documented for SwiftLint compliance.
    public static func monthURL(
        for date: Date,
        calendar: Calendar = .current
    ) -> URL? {
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        return routeURL(for: .month(year: year, month: month))
    }

    /// Documented for SwiftLint compliance.
    public static func itemURL(
        for itemID: String
    ) -> URL? {
        routeURL(for: .item(itemID))
    }

    /// Documented for SwiftLint compliance.
    public static func preferredItemURL(
        for itemID: String
    ) -> URL {
        preferredURL(for: .item(itemID))
    }

    /// Documented for SwiftLint compliance.
    public static func preferredMonthURL(
        for date: Date,
        calendar: Calendar = .current
    ) -> URL {
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        return preferredURL(for: .month(year: year, month: month))
    }
}
