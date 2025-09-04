//
//  Item.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

@Model
public final class Item {
    public private(set) var date = Date(timeIntervalSinceReferenceDate: .zero)
    public private(set) var content = String.empty
    public private(set) var income = Decimal.zero
    public private(set) var outgo = Decimal.zero
    public private(set) var repeatID = UUID()
    public private(set) var balance = Decimal.zero

    @Relationship(inverse: \Tag.items)
    public private(set) var tags: [Tag]?

    private init() {}

    public static func create(context: ModelContext,
                              date: Date,
                              content: String,
                              income: Decimal,
                              outgo: Decimal,
                              category: String,
                              repeatID: UUID) throws -> Item {
        let item = Item()
        context.insert(item)

        item.date = Calendar.utc.startOfDay(for: Calendar.utc.shiftedDate(componentsFrom: date, in: .current))
        item.content = content
        item.income = income
        item.outgo = outgo
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

    public func modify(date: Date,
                       content: String,
                       income: Decimal,
                       outgo: Decimal,
                       category: String,
                       repeatID: UUID) throws {
        self.date = Calendar.utc.startOfDay(for: Calendar.utc.shiftedDate(componentsFrom: date, in: .current))
        self.content = content
        self.income = income
        self.outgo = outgo
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

    public func modify(balance: Decimal) {
        self.balance = balance
    }

    public func modify(tags: [Tag]) {
        self.tags = tags
    }
}

extension Item {
    public var utcDate: Date {
        date
    }

    public var localDate: Date {
        Calendar.current.shiftedDate(componentsFrom: utcDate, in: .utc)
    }

    public var profit: Decimal {
        income - outgo
    }

    public var isProfitable: Bool {
        profit.isPlus
    }

    public var year: Tag? {
        tags?.first {
            $0.type == .year
        }
    }

    public var category: Tag? {
        tags?.first {
            $0.type == .category
        }
    }
}

extension Item: Comparable {
    public static func < (lhs: Item, rhs: Item) -> Bool {
        lhs.utcDate > rhs.utcDate
    }
}

// MARK: - Test

extension Item {
    public static func createIgnoringDuplicates(context: ModelContext,
                                                date: Date,
                                                content: String,
                                                income: Decimal,
                                                outgo: Decimal,
                                                category: String,
                                                repeatID: UUID) throws -> Item {
        let item = Item()
        context.insert(item)

        item.date = Calendar.utc.startOfDay(for: Calendar.utc.shiftedDate(componentsFrom: date, in: .current))
        item.content = content
        item.income = income
        item.outgo = outgo
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
