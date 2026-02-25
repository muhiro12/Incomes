import Foundation

enum IncomesIntentRouteOpener {
    static func monthIntent(for date: Date) -> OpenIncomesRouteIntent {
        .init(url: IncomesDeepLinkURLBuilder.preferredMonthURL(for: date))
    }

    static func homeIntent() -> OpenIncomesRouteIntent {
        routeIntent(for: .home)
    }

    static func routeIntent(for route: IncomesRoute) -> OpenIncomesRouteIntent {
        .init(url: IncomesDeepLinkURLBuilder.preferredURL(for: route))
    }
}
