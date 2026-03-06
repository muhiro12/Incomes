import Foundation
import MHDeepLinking

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
        switch destination {
        case "home":
            return .home
        case "settings":
            return Self.parseSettingsRoute(from: pathComponents)
        case "year-summary":
            return Self.parseYearSummaryRoute(from: pathComponents)
        case "yearly-duplication":
            return .yearlyDuplication
        case "duplicate-tags":
            return .duplicateTags
        case "year":
            return Self.parseYearRoute(from: pathComponents)
        case "month":
            return Self.parseMonthRoute(
                from: Array(pathComponents.dropFirst())
            )
        case "item":
            return Self.parseItemRoute(
                from: Array(pathComponents.dropFirst()),
                queryItems: queryItems
            )
        case "search":
            return Self.parseSearchRoute(queryItems: queryItems)
        default:
            return nil
        }
    }

    private static func parseSettingsRoute(from pathComponents: [String]) -> IncomesRoute? {
        guard pathComponents.count >= 2 else { // swiftlint:disable:this no_magic_numbers
            return .settings
        }

        switch pathComponents[1].lowercased() {
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

    private static func parseYearSummaryRoute(from pathComponents: [String]) -> IncomesRoute? {
        guard pathComponents.count >= 2, // swiftlint:disable:this no_magic_numbers
              let year = Self.parseYear(pathComponents[1]) else {
            return nil
        }
        return .yearSummary(year)
    }

    private static func parseYearRoute(from pathComponents: [String]) -> IncomesRoute? {
        guard pathComponents.count >= 2, // swiftlint:disable:this no_magic_numbers
              let year = Self.parseYear(pathComponents[1]) else {
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

    private static func parseMonthRoute(from segments: [String]) -> IncomesRoute? {
        guard let firstSegment = segments.first else {
            return nil
        }

        if segments.count >= 2 { // swiftlint:disable:this no_magic_numbers
            guard let year = parseYear(firstSegment),
                  let month = parseMonth(segments[1]) else {
                return nil
            }
            return .month(year: year, month: month)
        }

        let compactValue = firstSegment.replacingOccurrences(of: "-", with: "")
        guard compactValue.count == 6, // swiftlint:disable:this no_magic_numbers
              let year = parseYear(
                String(compactValue.prefix(4)) // swiftlint:disable:this no_magic_numbers
              ),
              let month = parseMonth(
                String(compactValue.suffix(2)) // swiftlint:disable:this no_magic_numbers
              ) else {
            return nil
        }
        return .month(year: year, month: month)
    }

    static func parseItemRoute(
        from segments: [String],
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
        guard value.count == 4, // swiftlint:disable:this no_magic_numbers
              let year = Int(value),
              1...9_999 ~= year else { // swiftlint:disable:this no_magic_numbers
            return nil
        }
        return year
    }

    static func parseMonth(_ value: String) -> Int? {
        guard let month = Int(value),
              1...12 ~= month else { // swiftlint:disable:this no_magic_numbers
            return nil
        }
        return month
    }
}
