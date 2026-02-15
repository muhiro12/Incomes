import Foundation

/// Builds shareable URLs from app routes.
public enum IncomesRouteURLBuilder {
    public static let customScheme = IncomesRouteParser.customScheme
    public static let defaultUniversalLinkHost = "muhiro12.github.io"
    public static let defaultUniversalLinkPathPrefix = "Incomes"

    public static func customSchemeURL(
        for route: IncomesRoute
    ) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = customScheme
        urlComponents.host = "v1"
        urlComponents.path = "/" + routePathSegments(route).joined(separator: "/")
        urlComponents.queryItems = routeQueryItems(route)
        return urlComponents.url
    }

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
        allPathSegments.append("v1")
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
        case .introduction:
            return ["introduction"]
        case .duplicateTags:
            return ["duplicate-tags"]
        case .year(let year):
            return ["year", String(format: "%04d", year)]
        case .month(let year, let month):
            let monthText = String(format: "%04d-%02d", year, month)
            return ["month", monthText]
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
        case .home,
             .settings,
             .settingsSubscription,
             .settingsLicense,
             .settingsDebug,
             .yearSummary,
             .yearlyDuplication,
             .introduction,
             .duplicateTags,
             .year,
             .month:
            return nil
        }
    }
}
