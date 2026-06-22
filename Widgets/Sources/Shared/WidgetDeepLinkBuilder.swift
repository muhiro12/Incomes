import Foundation

enum WidgetDeepLinkBuilder {
    nonisolated static func monthURL(for date: Date) -> URL {
        MainNavigationOperations.preferredMonthURL(for: date)
    }

    nonisolated static func itemURL(for itemID: String) -> URL {
        MainNavigationOperations.preferredRouteURL(for: .item(itemID))
    }

    nonisolated static func homeURL() -> URL {
        MainNavigationOperations.preferredRouteURL(for: .home)
    }
}
