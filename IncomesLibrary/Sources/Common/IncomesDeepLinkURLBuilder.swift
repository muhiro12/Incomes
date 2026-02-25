import Foundation

/// Builds universal-link deep link URLs used by external entry points.
public enum IncomesDeepLinkURLBuilder {
    public static func routeURL(for route: IncomesRoute) -> URL? {
        IncomesRouteURLBuilder.universalLinkURL(for: route)
    }

    public static func homeURL() -> URL? {
        routeURL(for: .home)
    }

    public static func monthURL(
        for date: Date,
        calendar: Calendar = .current
    ) -> URL? {
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        return routeURL(for: .month(year: year, month: month))
    }
}
