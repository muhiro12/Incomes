import Foundation
import MHPlatformCore

extension IncomesRoute: MHDeepLinkRoute {
    public var deepLinkDescriptor: MHDeepLinkDescriptor {
        switch self {
        case .home:
            .init(pathComponents: ["home"])
        case .settings:
            .init(pathComponents: ["settings"])
        case .settingsSubscription:
            .init(pathComponents: ["settings", "subscription"])
        case .settingsLicense:
            .init(pathComponents: ["settings", "license"])
        case .settingsDebug:
            .init(pathComponents: ["settings", "debug"])
        case .yearSummary(let year):
            .init(pathComponents: ["year-summary", String(format: "%04d", year)])
        case .yearlyDuplication:
            .init(pathComponents: ["yearly-duplication"])
        case .duplicateTags:
            .init(pathComponents: ["duplicate-tags"])
        case .orphanTags:
            .init(pathComponents: ["orphan-tags"])
        case .year(let year):
            .init(pathComponents: ["year", String(format: "%04d", year)])
        case let .month(year, month):
            .init(
                pathComponents: [
                    "month",
                    String(format: "%04d-%02d", year, month)
                ]
            )
        case .item(let itemID):
            .init(
                pathComponents: ["item"],
                queryItems: itemID.isNotEmpty ? [
                    .init(name: "id", value: itemID)
                ] : []
            )
        case .search(let query):
            .init(
                pathComponents: ["search"],
                queryItems: query?.isNotEmpty == true ? [
                    .init(name: "q", value: query)
                ] : []
            )
        }
    }

    public init?(deepLinkDescriptor: MHDeepLinkDescriptor) {
        let pathComponents = deepLinkDescriptor.pathComponents
        let queryItems = deepLinkDescriptor.queryItems

        guard let destination = pathComponents.first?.lowercased() else {
            self = .home
            return
        }

        guard let route = Self.parseRoute(
            destination: destination,
            pathComponents: pathComponents,
            queryItems: queryItems
        ) else {
            return nil
        }
        self = route
    }

    private static func parseRoute(
        destination: String,
        pathComponents: [String],
        queryItems: [URLQueryItem]
    ) -> IncomesRoute? {
        let routeSegments = pathComponents.dropFirst()

        switch destination {
        case "home":
            return .home
        case "settings":
            return Self.parseSettingsRoute(from: routeSegments)
        case "year-summary":
            return Self.parseYearSummaryRoute(from: routeSegments)
        case "yearly-duplication":
            return .yearlyDuplication
        case "duplicate-tags",
             "orphan-tags":
            return Self.parseTagManagementRoute(destination: destination)
        case "year":
            return Self.parseYearRoute(from: routeSegments)
        case "month":
            return Self.parseMonthRoute(
                from: routeSegments
            )
        case "item":
            return Self.parseItemRoute(
                from: routeSegments,
                queryItems: queryItems
            )
        case "search":
            return Self.parseSearchRoute(queryItems: queryItems)
        default:
            return nil
        }
    }

    private static func parseSettingsRoute(from segments: ArraySlice<String>) -> IncomesRoute? {
        guard let settingsDetail = segments.first else {
            return .settings
        }

        switch settingsDetail.lowercased() {
        case "subscription":
            return .settingsSubscription
        case "license":
            return .settingsLicense
        case "debug":
            return .settingsDebug
        default:
            return nil
        }
    }

    private static func parseYearSummaryRoute(from segments: ArraySlice<String>) -> IncomesRoute? {
        guard let yearValue = segments.first,
              let year = Self.parseYear(yearValue) else {
            return nil
        }
        return .yearSummary(year)
    }

    private static func parseTagManagementRoute(
        destination: String
    ) -> IncomesRoute? {
        switch destination {
        case "duplicate-tags":
            return .duplicateTags
        case "orphan-tags":
            return .orphanTags
        default:
            return nil
        }
    }

    private static func parseYearRoute(from segments: ArraySlice<String>) -> IncomesRoute? {
        guard let yearValue = segments.first,
              let year = Self.parseYear(yearValue) else {
            return nil
        }
        return .year(year)
    }

    private static func parseSearchRoute(queryItems: [URLQueryItem]) -> IncomesRoute {
        let query = queryItems.first { queryItem in
            queryItem.name == "q"
        }?.value
        return .search(query: query)
    }

    private static func parseMonthRoute(from segments: ArraySlice<String>) -> IncomesRoute? {
        guard let firstSegment = segments.first else {
            return nil
        }

        if let monthValue = segments.dropFirst().first {
            guard let year = parseYear(firstSegment),
                  let month = parseMonth(monthValue) else {
                return nil
            }
            return .month(year: year, month: month)
        }

        let compactValue = firstSegment.replacingOccurrences(of: "-", with: "")
        guard compactValue.count == YearMonthComponentRules.compactYearMonthDigitCount,
              let year = parseYear(
                String(compactValue.prefix(YearMonthComponentRules.yearDigitCount))
              ),
              let month = parseMonth(
                String(compactValue.suffix(YearMonthComponentRules.monthDigitCount))
              ) else {
            return nil
        }
        return .month(year: year, month: month)
    }

    static func parseItemRoute(
        from segments: ArraySlice<String>,
        queryItems: [URLQueryItem]
    ) -> IncomesRoute? {
        if let itemID = segments.first,
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

    static func parseYear(_ value: String) -> Int? {
        guard value.count == YearMonthComponentRules.yearDigitCount,
              let year = Int(value),
              YearMonthComponentRules.isValidYear(year) else {
            return nil
        }
        return year
    }

    static func parseMonth(_ value: String) -> Int? {
        guard let month = Int(value),
              YearMonthComponentRules.isValidMonth(month) else {
            return nil
        }
        return month
    }
}
