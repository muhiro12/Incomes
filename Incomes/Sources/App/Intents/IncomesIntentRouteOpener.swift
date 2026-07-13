import Foundation

enum IncomesIntentRouteOpener {
    static func monthIntent(for date: Date) -> OpenIncomesRouteIntent {
        .init(
            url: MainNavigationOperations.preferredMonthURL(for: date)
        )
    }
}
