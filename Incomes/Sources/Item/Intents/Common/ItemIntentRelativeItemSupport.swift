import AppIntents
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

    static func entity(
        context: ModelContext,
        date: Date,
        direction: Direction
    ) throws -> ItemEntity? {
        let item = try item(
            context: context,
            date: date,
            direction: direction
        )
        return try ItemIntentEntitySupport.entity(from: item)
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

    static func entities(
        context: ModelContext,
        date: Date,
        direction: Direction
    ) throws -> [ItemEntity] {
        let items = try items(
            context: context,
            date: date,
            direction: direction
        )
        return try ItemIntentEntitySupport.entities(from: items)
    }

    static func content(
        context: ModelContext,
        date: Date,
        direction: Direction
    ) throws -> String? {
        let item = try item(
            context: context,
            date: date,
            direction: direction
        )
        return item?.content
    }

    static func localDate(
        context: ModelContext,
        date: Date,
        direction: Direction
    ) throws -> Date? {
        let item = try item(
            context: context,
            date: date,
            direction: direction
        )
        return item?.localDate
    }

    static func netIncomeAmount(
        context: ModelContext,
        date: Date,
        direction: Direction
    ) throws -> IntentCurrencyAmount? {
        let item = try item(
            context: context,
            date: date,
            direction: direction
        )
        return ItemIntentCurrencySupport.amount(from: item?.netIncome)
    }
}
