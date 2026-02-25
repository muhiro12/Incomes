import Foundation

enum WidgetDeepLinkBuilder {
    static func monthURL(for date: Date) -> URL? {
        IncomesDeepLinkURLBuilder.monthURL(for: date)
    }

    static func itemURL(for itemID: String) -> URL? {
        IncomesDeepLinkURLBuilder.itemURL(for: itemID)
    }

    static func homeURL() -> URL? {
        IncomesDeepLinkURLBuilder.homeURL()
    }
}
