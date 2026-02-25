import Foundation

enum WidgetDeepLinkBuilder {
    static func monthURL(for date: Date) -> URL? {
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        return IncomesRouteURLBuilder.universalLinkURL(
            for: .month(year: year, month: month)
        )
    }

    static func homeURL() -> URL? {
        IncomesRouteURLBuilder.universalLinkURL(for: .home)
    }
}
