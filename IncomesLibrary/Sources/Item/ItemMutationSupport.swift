import Foundation
import SwiftData

enum ItemMutationSupport {
    static let followUpHints: Set<MutationOutcome.FollowUpHint> = [
        .refreshNotificationSchedule,
        .reloadWidgets,
        .refreshWatchSnapshot
    ]

    static func dateRange(from dates: [Date]) -> ClosedRange<Date>? {
        guard let minDate = dates.min(),
              let maxDate = dates.max() else {
            return nil
        }
        return minDate...maxDate
    }

    static func itemsForMutationScope(
        context: ModelContext,
        item: Item,
        scope: ItemMutationScope
    ) throws -> [Item] {
        switch scope {
        case .thisItem:
            return [item]
        case .futureItems:
            return try context.fetch(
                .items(
                    .repeatIDAndDateIsAfter(
                        repeatID: item.repeatID,
                        date: item.localDate
                    )
                )
            )
        case .allItems:
            return try context.fetch(
                .items(.repeatIDIs(item.repeatID))
            )
        }
    }

    static func cleanupCandidateTags(from items: [Item]) -> [Tag] {
        items.flatMap { item in
            item.tags.orEmpty.filter { tag in
                switch tag.type {
                case .year, .yearMonth, .content, .category:
                    return true
                case .debug, .none:
                    return false
                }
            }
        }
    }
}
