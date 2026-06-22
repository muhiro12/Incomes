import Foundation

enum IncomesIntentRouteOpener {
    static func monthIntent(for date: Date) -> OpenIncomesRouteIntent {
        .init(
            url: MainNavigationOperations.preferredMonthURL(for: date)
        )
    }

    static func homeIntent() -> OpenIncomesRouteIntent {
        routeIntent(for: .home)
    }

    static func routeIntent(for route: IncomesRoute) -> OpenIncomesRouteIntent {
        .init(
            url: MainNavigationOperations.preferredRouteURL(for: route)
        )
    }
}
