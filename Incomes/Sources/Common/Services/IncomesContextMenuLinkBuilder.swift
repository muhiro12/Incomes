import Foundation
import SwiftData

enum IncomesContextMenuLinkBuilder {
    static func preferredURL(
        for route: IncomesRoute?
    ) -> URL? {
        guard let route else {
            return nil
        }
        return IncomesDeepLinkURLBuilder.preferredURL(for: route)
    }

    static func preferredURL(
        for item: Item
    ) -> URL? {
        guard let itemID = try? PersistentIdentifierCoder.encode(item.id) else {
            return nil
        }
        return IncomesDeepLinkURLBuilder.preferredItemURL(for: itemID)
    }

    static func yearRoute(
        for tag: Tag
    ) -> IncomesRoute? {
        guard let year = yearValue(from: tag) else {
            return nil
        }
        return .year(year)
    }

    static func yearSummaryRoute(
        for tag: Tag
    ) -> IncomesRoute? {
        guard let year = yearValue(from: tag) else {
            return nil
        }
        return .yearSummary(year)
    }

    static func monthRoute(
        for tag: Tag
    ) -> IncomesRoute? {
        guard tag.type == .yearMonth,
              let date = TagService.date(for: tag) else {
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
              1...9_999 ~= year else { // swiftlint:disable:this no_magic_numbers
            return nil
        }
        return year
    }
}
