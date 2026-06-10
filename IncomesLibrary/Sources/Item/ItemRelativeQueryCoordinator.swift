//
//  ItemRelativeQueryCoordinator.swift
//  Incomes
//
//  Created by Codex on 2026/06/10.
//

import Foundation
import SwiftData

/// Coordinates relative item queries around a reference date.
public enum ItemRelativeQueryCoordinator {
    /// Relative query direction from the reference date.
    public enum Direction {
        /// Query items on or after the reference date.
        case next
        /// Query items on or before the reference date.
        case previous
    }

    /// Returns the nearest item in the requested direction.
    public static func item(
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

    /// Returns all items on the same local day as the nearest relative item.
    public static func items(
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

    /// Returns the content of the nearest item in the requested direction.
    public static func content(
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

    /// Returns the local date of the nearest item in the requested direction.
    public static func localDate(
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

    /// Returns the net income of the nearest item in the requested direction.
    public static func netIncome(
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
