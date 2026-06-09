import Foundation
import SwiftData

enum ItemIntentRelativeItemSupport {
    typealias Direction = ItemRelativeQueryCoordinator.Direction

    static func entity(
        context: ModelContext,
        date: Date,
        direction: Direction
    ) throws -> ItemEntity? {
        let item = try ItemRelativeQueryCoordinator.item(
            context: context,
            date: date,
            direction: direction
        )
        return try ItemIntentEntitySupport.entity(from: item)
    }

    static func entities(
        context: ModelContext,
        date: Date,
        direction: Direction
    ) throws -> [ItemEntity] {
        let items = try ItemRelativeQueryCoordinator.items(
            context: context,
            date: date,
            direction: direction
        )
        return try ItemIntentEntitySupport.entities(from: items)
    }
}
