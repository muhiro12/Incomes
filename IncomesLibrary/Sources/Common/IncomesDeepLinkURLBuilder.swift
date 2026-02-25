import Foundation

/// Builds universal-link deep link URLs used by external entry points.
public enum IncomesDeepLinkURLBuilder {
    public static func routeURL(for route: IncomesRoute) -> URL? {
        IncomesRouteURLBuilder.universalLinkURL(for: route)
    }

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
        return .init(
            string: "\(IncomesRouteURLDefaults.customScheme)://\(IncomesRouteURLDefaults.routeVersionPathSegment)/home"
        )!
    }

    public static func homeURL() -> URL? {
        routeURL(for: .home)
    }

    public static func preferredHomeURL() -> URL {
        preferredURL(for: .home)
    }

    public static func monthURL(
        for date: Date,
        calendar: Calendar = .current
    ) -> URL? {
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        return routeURL(for: .month(year: year, month: month))
    }

    public static func preferredMonthURL(
        for date: Date,
        calendar: Calendar = .current
    ) -> URL {
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        return preferredURL(for: .month(year: year, month: month))
    }
}
