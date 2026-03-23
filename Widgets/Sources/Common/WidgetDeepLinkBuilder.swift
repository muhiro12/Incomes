import Foundation

enum WidgetDeepLinkBuilder {
    nonisolated static func monthURL(for date: Date) -> URL? {
        IncomesDeepLinkURLBuilder.monthURL(for: date)
    }

    nonisolated static func itemURL(for itemID: String) -> URL? {
        IncomesDeepLinkURLBuilder.itemURL(for: itemID)
    }

    nonisolated static func homeURL() -> URL? {
        IncomesDeepLinkURLBuilder.homeURL()
    }
}
