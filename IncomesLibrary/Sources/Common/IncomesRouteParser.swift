import Foundation

/// Parses incoming URLs and maps them to app navigation routes.
public enum IncomesRouteParser {
    public static let customScheme = "incomes"
    public static let universalLinkHosts: Set<String> = ["muhiro12.github.io"]

    public static func parse(
        url: URL,
        allowedUniversalLinkHosts: Set<String> = universalLinkHosts
    ) -> IncomesRoute? {
        guard let scheme = url.scheme?.lowercased() else {
            return nil
        }

        let pathSegments: [String]
        switch scheme {
        case "http", "https":
            guard let host = url.host?.lowercased(),
                  allowedUniversalLinkHosts.contains(host) else {
                return nil
            }
            pathSegments = normalizedPathSegments(from: url.pathComponents)
        case customScheme:
            var normalizedSegments = [String]()
            if let host = url.host,
               host.isNotEmpty {
                normalizedSegments.append(host)
            }
            normalizedSegments.append(
                contentsOf: normalizedPathSegments(from: url.pathComponents)
            )
            pathSegments = normalizedSegments
        default:
            return nil
        }

        return route(
            from: pathSegments,
            queryItems: URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems ?? []
        )
    }
}

private extension IncomesRouteParser {
    static func normalizedPathSegments(from pathComponents: [String]) -> [String] {
        pathComponents.filter { pathComponent in
            pathComponent != "/"
        }
    }

    static func route(
        from pathSegments: [String],
        queryItems: [URLQueryItem]
    ) -> IncomesRoute? {
        var normalizedSegments = pathSegments
        if normalizedSegments.first?.lowercased() == "incomes" {
            _ = normalizedSegments.removeFirst()
        }
        if normalizedSegments.first?.lowercased() == "v1" {
            _ = normalizedSegments.removeFirst()
        }
        guard let destination = normalizedSegments.first?.lowercased() else {
            return .home
        }

        switch destination {
        case "home":
            return .home
        case "settings":
            return .settings
        case "year":
            guard normalizedSegments.count >= 2,
                  let year = parseYear(from: normalizedSegments[1]) else {
                return nil
            }
            return .year(year)
        case "month":
            return parseMonthRoute(
                from: Array(normalizedSegments.dropFirst())
            )
        case "search":
            let query = queryItems.first { queryItem in
                queryItem.name == "q"
            }?.value
            return .search(query: query)
        default:
            return nil
        }
    }

    static func parseMonthRoute(
        from monthSegments: [String]
    ) -> IncomesRoute? {
        guard let firstSegment = monthSegments.first else {
            return nil
        }

        if monthSegments.count >= 2 {
            guard let year = parseYear(from: firstSegment),
                  let month = parseMonth(from: monthSegments[1]) else {
                return nil
            }
            return .month(year: year, month: month)
        }

        let compactValue = firstSegment.replacingOccurrences(of: "-", with: "")
        guard compactValue.count == 6,
              let year = parseYear(
                from: String(compactValue.prefix(4))
              ),
              let month = parseMonth(
                from: String(compactValue.suffix(2))
              ) else {
            return nil
        }
        return .month(year: year, month: month)
    }

    static func parseYear(from value: String) -> Int? {
        guard value.count == 4,
              let year = Int(value),
              1...9_999 ~= year else {
            return nil
        }
        return year
    }

    static func parseMonth(from value: String) -> Int? {
        guard let month = Int(value),
              1...12 ~= month else {
            return nil
        }
        return month
    }
}
