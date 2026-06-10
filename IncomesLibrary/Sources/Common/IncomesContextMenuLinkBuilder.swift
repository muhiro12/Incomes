import Foundation

/// Builds routes and URLs for context-menu link actions.
public enum IncomesContextMenuLinkBuilder {
    /// Returns the preferred deep link for `route`.
    public static func preferredURL(
        for route: IncomesRoute?
    ) -> URL? {
        guard let route else {
            return nil
        }
        return IncomesDeepLinkURLBuilder.preferredURL(for: route)
    }

    /// Returns the preferred item deep link for `item`.
    public static func preferredURL(
        for item: Item
    ) -> URL? {
        guard let itemID = try? PersistentIdentifierCoder.encode(item.id) else {
            return nil
        }
        return IncomesDeepLinkURLBuilder.preferredItemURL(for: itemID)
    }

    /// Returns the year route represented by a year tag.
    public static func yearRoute(
        for tag: Tag
    ) -> IncomesRoute? {
        guard let year = yearValue(from: tag) else {
            return nil
        }
        return .year(year)
    }

    /// Returns the year summary route represented by a year tag.
    public static func yearSummaryRoute(
        for tag: Tag
    ) -> IncomesRoute? {
        guard let year = yearValue(from: tag) else {
            return nil
        }
        return .yearSummary(year)
    }

    /// Returns the month route represented by a year-month tag.
    public static func monthRoute(
        for tag: Tag
    ) -> IncomesRoute? {
        guard tag.type == .yearMonth,
              let date = TagQueryOperations.date(for: tag) else {
            return nil
        }
        let calendar = Calendar.current
        return .month(
            year: calendar.component(.year, from: date),
            month: calendar.component(.month, from: date)
        )
    }
}

private extension IncomesContextMenuLinkBuilder {
    static func yearValue(
        from tag: Tag
    ) -> Int? {
        guard tag.type == .year,
              let year = Int(tag.name),
              YearMonthComponentRules.isValidYear(year) else {
            return nil
        }
        return year
    }
}
