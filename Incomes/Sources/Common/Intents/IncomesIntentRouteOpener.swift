import Foundation

enum IncomesIntentRouteOpener {
    private static var fallbackHomeURL: URL {
        guard let homeURL = MainNavigationOperations.preferredURL(for: .home) else {
            preconditionFailure("Failed to build fallback home URL.")
        }
        return homeURL
    }

    static func monthIntent(for date: Date) -> OpenIncomesRouteIntent {
        .init(
            url: MainNavigationOperations.preferredURL(
                forMonthContaining: date
            ) ?? fallbackHomeURL
        )
    }

    static func homeIntent() -> OpenIncomesRouteIntent {
        routeIntent(for: .home)
    }

    static func routeIntent(for route: IncomesRoute) -> OpenIncomesRouteIntent {
        .init(url: MainNavigationOperations.preferredURL(for: route) ?? fallbackHomeURL)
    }
}
