import Foundation

enum WidgetDeepLinkBuilder {
    nonisolated static func monthURL(for date: Date) -> URL? {
        MainNavigationOperations.preferredURL(forMonthContaining: date)
    }

    nonisolated static func itemURL(for itemID: String) -> URL? {
        guard !itemID.isEmpty else {
            return nil
        }
        return MainNavigationOperations.preferredURL(for: .item(itemID))
    }

    nonisolated static func homeURL() -> URL? {
        MainNavigationOperations.preferredURL(for: .home)
    }
}
