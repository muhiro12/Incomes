//
//  Item.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//

import Foundation
import SwiftData

/// A financial record representing one income/outgo entry with tags.
@Model
public final class Item {
    /// Documented for SwiftLint compliance.
    @available(iOS, deprecated: 100000.0, message: "Use `utcDate` (UTC) or `localDate` (current calendar) instead.")
    public private(set) var date = Date(timeIntervalSinceReferenceDate: .zero)
    /// Documented for SwiftLint compliance.
    public private(set) var content = String.empty
    /// Documented for SwiftLint compliance.
    public private(set) var income = Decimal.zero
    /// Documented for SwiftLint compliance.
    public private(set) var outgo = Decimal.zero
    /// Documented for SwiftLint compliance.
    public private(set) var priority = 0
    /// Documented for SwiftLint compliance.
    public private(set) var repeatID = UUID()
    /// Documented for SwiftLint compliance.
    public private(set) var balance = Decimal.zero

    /// Documented for SwiftLint compliance.
    @Relationship(inverse: \Tag.items)
    public private(set) var tags: [Tag]?

    private init() {
        // no-op
    }

    /// Creates a new item and attaches year/month/content/category tags.
    public static func create(context: ModelContext,
                              date: Date,
                              content: String,
                              income: Decimal,
                              outgo: Decimal,
                              category: String,
                              priority: Int,
                              repeatID: UUID) throws -> Item {
        let item = Item()
        context.insert(item)

        item.date = Calendar.utc.startOfDay(for: Calendar.utc.shiftedDate(componentsFrom: date, in: .current))
        item.content = content
        item.income = income
        item.outgo = outgo
        item.priority = priority
        item.repeatID = repeatID

        item.tags = [
            try .create(
                context: context,
                name: date.stringValueWithoutLocale(.yyyy),
                type: .year
            ),
            try .create(
                context: context,
                name: date.stringValueWithoutLocale(.yyyyMM),
                type: .yearMonth
            ),
            try .create(
                context: context,
                name: content,
                type: .content
            ),
            try .create(
                context: context,
                name: category,
                type: .category
            )
        ]

        return item
    }

    /// Updates core fields and reattaches derived tags based on the new values.
    public func modify(date: Date,
                       content: String,
                       income: Decimal,
                       outgo: Decimal,
                       category: String,
                       priority: Int,
                       repeatID: UUID) throws {
        self.date = Calendar.utc.startOfDay(for: Calendar.utc.shiftedDate(componentsFrom: date, in: .current))
        self.content = content
        self.income = income
        self.outgo = outgo
        self.priority = priority
        self.repeatID = repeatID

        guard let context = modelContext else {
            return
        }

        self.tags = [
            try .create(
                context: context,
                name: date.stringValueWithoutLocale(.yyyy),
                type: .year
            ),
            try .create(
                context: context,
                name: date.stringValueWithoutLocale(.yyyyMM),
                type: .yearMonth
            ),
            try .create(
                context: context,
                name: content,
                type: .content
            ),
            try .create(
                context: context,
                name: category,
                type: .category
            )
        ]
    }

    /// Updates the computed balance field.
    public func modify(balance: Decimal) {
        self.balance = balance
    }

    /// Replaces current tags with `tags`.
    public func modify(tags: [Tag]) {
        self.tags = tags
    }
}

extension Item {
    /// UTC date persisted in the store.
    public var utcDate: Date {
        date
    }

    /// Local calendar date derived from `utcDate`.
    public var localDate: Date {
        Calendar.current.shiftedDate(componentsFrom: utcDate, in: .utc)
    }

    /// `income - outgo`.
    public var netIncome: Decimal {
        income - outgo
    }

    /// True when `netIncome >= 0`.
    public var isNetIncomePositive: Bool {
        netIncome.isPlus
    }

    /// Year tag if present.
    public var year: Tag? {
        tags?.first { tag in
            tag.type == .year
        }
    }

    /// Category tag if present.
    public var category: Tag? {
        tags?.first { tag in
            tag.type == .category
        }
    }
}

extension Item: Comparable {
    public static func < (lhs: Item, rhs: Item) -> Bool {
        if lhs.utcDate != rhs.utcDate {
            return lhs.utcDate > rhs.utcDate
        }
        if lhs.priority != rhs.priority {
            return lhs.priority < rhs.priority
        }
        if lhs.content != rhs.content {
            return lhs.content > rhs.content
        }
        return String(describing: lhs.persistentModelID) > String(describing: rhs.persistentModelID)
    }
}

// MARK: - Test

extension Item {
    /// Testing helper: creates an item without checking duplicate tags.
    public static func createIgnoringDuplicates(context: ModelContext,
                                                date: Date,
                                                content: String,
                                                income: Decimal,
                                                outgo: Decimal,
                                                category: String,
                                                priority: Int,
                                                repeatID: UUID) throws -> Item {
        let item = Item()
        context.insert(item)

        item.date = Calendar.utc.startOfDay(for: Calendar.utc.shiftedDate(componentsFrom: date, in: .current))
        item.content = content
        item.income = income
        item.outgo = outgo
        item.priority = priority
        item.repeatID = repeatID

        item.tags = [
            try .createIgnoringDuplicates(
                context: context,
                name: date.stringValueWithoutLocale(.yyyy),
                type: .year
            ),
            try .createIgnoringDuplicates(
                context: context,
                name: date.stringValueWithoutLocale(.yyyyMM),
                type: .yearMonth
            ),
            try .createIgnoringDuplicates(
                context: context,
                name: content,
                type: .content
            ),
            try .createIgnoringDuplicates(
                context: context,
                name: category,
                type: .category
            )
        ]

        return item
    }
}
