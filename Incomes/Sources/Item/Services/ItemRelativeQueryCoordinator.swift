//
//  ItemRelativeQueryCoordinator.swift
//  Incomes
//
//  Created by Codex on 2026/06/10.
//

import Foundation
import SwiftData

enum ItemRelativeQueryCoordinator {
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

    static func netIncome(
        context: ModelContext,
        date: Date,
        direction: Direction
    ) throws -> Decimal? {
        let item = try item(
            context: context,
            date: date,
            direction: direction
        )
        return item?.netIncome
    }
}
