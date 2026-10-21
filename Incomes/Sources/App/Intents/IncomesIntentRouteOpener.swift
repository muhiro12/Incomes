import Foundation

enum IncomesIntentRouteOpener {
    static func monthIntent(
        for date: Date,
        ledgerIdentifier: LedgerIdentifier = .default
    ) -> OpenIncomesRouteIntent {
        if ledgerIdentifier == .default {
            return .init(url: MainNavigationOperations.preferredMonthURL(for: date))
        }
        return routeIntent(for: .ledgerMonth(
            ledgerIdentifier.rawValue,
            year: Calendar.current.component(.year, from: date),
            month: Calendar.current.component(.month, from: date)
        ))
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
