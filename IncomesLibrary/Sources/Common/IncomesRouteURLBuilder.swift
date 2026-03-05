import Foundation

/// Builds shareable URLs from app routes.
public enum IncomesRouteURLBuilder {
    /// Documented for SwiftLint compliance.
    public static let customScheme = IncomesRouteURLDefaults.customScheme
    /// Documented for SwiftLint compliance.
    public static let defaultUniversalLinkHost = IncomesRouteURLDefaults.universalLinkHost
    /// Documented for SwiftLint compliance.
    public static let defaultUniversalLinkPathPrefix = IncomesRouteURLDefaults.universalLinkPathPrefix

    /// Documented for SwiftLint compliance.
    public static func customSchemeURL(
        for route: IncomesRoute
    ) -> URL? {
        let pathSegments = routePathSegments(route)
        var urlComponents = URLComponents()
        urlComponents.scheme = customScheme
        urlComponents.host = pathSegments.first
        if pathSegments.count >= 2 {
            urlComponents.path = "/" + pathSegments.dropFirst().joined(separator: "/")
        } else {
            urlComponents.path = .empty
        }
        urlComponents.queryItems = routeQueryItems(route)
        return urlComponents.url
    }

    /// Documented for SwiftLint compliance.
    public static func universalLinkURL(
        for route: IncomesRoute,
        host: String = defaultUniversalLinkHost,
        appPathPrefix: String = defaultUniversalLinkPathPrefix
    ) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = host

        var allPathSegments = [String]()
        if appPathPrefix.isNotEmpty {
            allPathSegments.append(appPathPrefix)
        }
        allPathSegments.append(contentsOf: routePathSegments(route))
        urlComponents.path = "/" + allPathSegments.joined(separator: "/")
        urlComponents.queryItems = routeQueryItems(route)
        return urlComponents.url
    }
}

private extension IncomesRouteURLBuilder {
    static func routePathSegments(_ route: IncomesRoute) -> [String] {
        switch route {
        case .home:
            return ["home"]
        case .settings:
            return ["settings"]
        case .settingsSubscription:
            return ["settings", "subscription"]
        case .settingsLicense:
            return ["settings", "license"]
        case .settingsDebug:
            return ["settings", "debug"]
        case .yearSummary(let year):
            return ["year-summary", String(format: "%04d", year)]
        case .yearlyDuplication:
            return ["yearly-duplication"]
        case .duplicateTags:
            return ["duplicate-tags"]
        case .year(let year):
            return ["year", String(format: "%04d", year)]
        case let .month(year, month):
            let monthText = String(format: "%04d-%02d", year, month)
            return ["month", monthText]
        case .item:
            return ["item"]
        case .search:
            return ["search"]
        }
    }

    static func routeQueryItems(
        _ route: IncomesRoute
    ) -> [URLQueryItem]? {
        switch route {
        case .search(let query):
            guard let query,
                  query.isNotEmpty else {
                return nil
            }
            return [
                .init(name: "q", value: query)
            ]
        case .item(let itemID):
            guard itemID.isNotEmpty else {
                return nil
            }
            return [
                .init(name: "id", value: itemID)
            ]
        case .home,
             .settings,
             .settingsSubscription,
             .settingsLicense,
             .settingsDebug,
             .yearSummary,
             .yearlyDuplication,
             .duplicateTags,
             .year,
             .month:
            return nil
        }
    }
}
