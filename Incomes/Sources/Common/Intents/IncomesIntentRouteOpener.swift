import Foundation

enum IncomesIntentRouteOpener {
    static func monthIntent(for date: Date) -> OpenIncomesRouteIntent {
        .init(url: resolvedMonthURL(for: date))
    }

    static func homeIntent() -> OpenIncomesRouteIntent {
        routeIntent(for: .home)
    }

    static func routeIntent(for route: IncomesRoute) -> OpenIncomesRouteIntent {
        .init(url: resolvedURL(for: route))
    }
}

private extension IncomesIntentRouteOpener {
    static func resolvedMonthURL(for date: Date) -> URL {
        if let deepLinkURL = IncomesDeepLinkURLBuilder.monthURL(for: date) {
            return deepLinkURL
        }
        assertionFailure("Failed to build month deep link URL.")
        return .init(string: "\(IncomesRouteURLDefaults.customScheme)://v1/home")!
    }

    static func resolvedURL(for route: IncomesRoute) -> URL {
        if let deepLinkURL = IncomesDeepLinkURLBuilder.routeURL(for: route) {
            return deepLinkURL
        }
        assertionFailure("Failed to build deep link URL.")
        return .init(string: "\(IncomesRouteURLDefaults.customScheme)://v1/home")!
    }
}
