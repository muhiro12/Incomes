import Foundation

/// Parses incoming URLs and maps them to app navigation routes.
public enum IncomesRouteParser {
    /// Documented for SwiftLint compliance.
    public static let customScheme = IncomesRouteURLDefaults.customScheme
    /// Documented for SwiftLint compliance.
    public static let universalLinkHosts: Set<String> = [
        IncomesRouteURLDefaults.universalLinkHost
    ]

    /// Documented for SwiftLint compliance.
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

    static func route( // swiftlint:disable:this cyclomatic_complexity function_body_length
        from pathSegments: [String],
        queryItems: [URLQueryItem]
    ) -> IncomesRoute? {
        var normalizedSegments = pathSegments
        if normalizedSegments.first?.lowercased() ==
            IncomesRouteURLDefaults.universalLinkPathPrefix.lowercased() {
            _ = normalizedSegments.removeFirst()
        }
        guard let destination = normalizedSegments.first?.lowercased() else {
            return .home
        }

        switch destination {
        case "home":
            return .home
        case "settings":
            guard normalizedSegments.count >= 2 else { // swiftlint:disable:this no_magic_numbers
                return .settings
            }
            let settingsDestination = normalizedSegments[1].lowercased()
            switch settingsDestination {
            case "subscription":
                return .settingsSubscription
            case "license":
                return .settingsLicense
            case "debug":
                return .settingsDebug
            default:
                return nil
            }
        case "year-summary":
            guard normalizedSegments.count >= 2, // swiftlint:disable:this no_magic_numbers
                  let year = parseYear(from: normalizedSegments[1]) else {
                return nil
            }
            return .yearSummary(year)
        case "yearly-duplication":
            return .yearlyDuplication
        case "duplicate-tags":
            return .duplicateTags
        case "year":
            guard normalizedSegments.count >= 2, // swiftlint:disable:this no_magic_numbers
                  let year = parseYear(from: normalizedSegments[1]) else {
                return nil
            }
            return .year(year)
        case "month":
            return parseMonthRoute(
                from: Array(normalizedSegments.dropFirst())
            )
        case "item":
            return parseItemRoute(
                from: Array(normalizedSegments.dropFirst()),
                queryItems: queryItems
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

        if monthSegments.count >= 2 { // swiftlint:disable:this no_magic_numbers
            guard let year = parseYear(from: firstSegment),
                  let month = parseMonth(from: monthSegments[1]) else {
                return nil
            }
            return .month(year: year, month: month)
        }

        let compactValue = firstSegment.replacingOccurrences(of: "-", with: "")
        guard compactValue.count == 6, // swiftlint:disable:this no_magic_numbers
              let year = parseYear(
                from: String(compactValue.prefix(4)) // swiftlint:disable:this no_magic_numbers
              ),
              let month = parseMonth(
                from: String(compactValue.suffix(2)) // swiftlint:disable:this no_magic_numbers
              ) else {
            return nil
        }
        return .month(year: year, month: month)
    }

    static func parseItemRoute(
        from itemSegments: [String],
        queryItems: [URLQueryItem]
    ) -> IncomesRoute? {
        if let itemID = itemSegments.first,
           itemID.isNotEmpty {
            return .item(itemID)
        }
        let itemID = queryItems.first { queryItem in
            queryItem.name == "id"
        }?.value
        guard let itemID,
              itemID.isNotEmpty else {
            return nil
        }
        return .item(itemID)
    }

    static func parseYear(from value: String) -> Int? {
        guard value.count == 4, // swiftlint:disable:this no_magic_numbers
              let year = Int(value),
              1...9_999 ~= year else { // swiftlint:disable:this no_magic_numbers
            return nil
        }
        return year
    }

    static func parseMonth(from value: String) -> Int? {
        guard let month = Int(value),
              1...12 ~= month else { // swiftlint:disable:this no_magic_numbers
            return nil
        }
        return month
    }
}
