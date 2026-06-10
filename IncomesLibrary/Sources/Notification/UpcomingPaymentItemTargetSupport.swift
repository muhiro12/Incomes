import Foundation

enum UpcomingPaymentItemTargetSupport {
    static func targetContentIdentifier(for item: Item) -> String {
        if let itemID = try? PersistentIdentifierCoder.encode(item.id) {
            return itemID
        }
        return String(describing: item.persistentModelID)
    }

    static func primaryRouteURL(for item: Item) -> URL {
        if let itemID = try? PersistentIdentifierCoder.encode(item.id) {
            return IncomesDeepLinkURLBuilder.preferredItemURL(for: itemID)
        }
        return IncomesDeepLinkURLBuilder.preferredMonthURL(for: item.localDate)
    }

    static func secondaryRouteURL(
        for item: Item,
        calendar: Calendar
    ) -> URL {
        IncomesDeepLinkURLBuilder.preferredMonthURL(
            for: item.localDate,
            calendar: calendar
        )
    }
}
