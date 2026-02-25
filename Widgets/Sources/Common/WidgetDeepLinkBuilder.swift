import Foundation

enum WidgetDeepLinkBuilder {
    static func monthURL(for date: Date) -> URL? {
        IncomesDeepLinkURLBuilder.monthURL(for: date)
    }

    static func homeURL() -> URL? {
        IncomesDeepLinkURLBuilder.homeURL()
    }
}
