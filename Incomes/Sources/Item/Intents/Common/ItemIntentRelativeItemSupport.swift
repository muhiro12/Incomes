import Foundation
import SwiftData

enum ItemIntentRelativeItemSupport {
    enum Direction {
        case next
        case previous
    }

    static func item(
        context: ModelContext,
        date: Date,
        direction: Direction
    ) throws -> Item? {
        switch direction {
        case .next:
            try ItemQueryOperations.nextItem(
                context: context,
                date: date
            )
        case .previous:
            try ItemQueryOperations.previousItem(
                context: context,
                date: date
            )
        }
    }

    static func items(
        context: ModelContext,
        date: Date,
        direction: Direction
    ) throws -> [Item] {
        switch direction {
        case .next:
            try ItemQueryOperations.nextItems(
                context: context,
                date: date
            )
        case .previous:
            try ItemQueryOperations.previousItems(
                context: context,
                date: date
            )
        }
    }
}
