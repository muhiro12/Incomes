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
final class Item {
    private(set) var date = Date(timeIntervalSinceReferenceDate: .zero)
    private(set) var content = String.empty
    private(set) var income = Decimal.zero
    private(set) var outgo = Decimal.zero
    private(set) var repeatID = UUID()
    private(set) var balance = Decimal.zero

    @Relationship(inverse: \Tag.items)
    private(set) var tags: [Tag]?

    private init() {}

    static func create(context: ModelContext,
                       date: Date,
                       content: String,
                       income: Decimal,
                       outgo: Decimal,
                       group: String,
                       repeatID: UUID) throws -> Item {
        let item = Item()
        context.insert(item)

        item.date = Calendar.utc.startOfDay(for: date)
        item.content = content
        item.income = income
        item.outgo = outgo
        item.repeatID = repeatID

        item.tags = [
            try .create(
                context: context,
                name: Calendar.utc.startOfYear(for: date).stringValueWithoutLocale(.yyyy),
                type: .year
            ),
            try .create(
                context: context,
                name: Calendar.utc.startOfMonth(for: date).stringValueWithoutLocale(.yyyyMM),
                type: .yearMonth
            ),
            try .create(
                context: context,
                name: content,
                type: .content
            ),
            try .create(
                context: context,
                name: group,
                type: .category
            )
        ]

        return item
    }

    func modify(date: Date,
                content: String,
                income: Decimal,
                outgo: Decimal,
                group: String,
                repeatID: UUID) throws {
        self.date = Calendar.utc.startOfDay(for: date)
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
                name: Calendar.utc.startOfYear(for: date).stringValueWithoutLocale(.yyyy),
                type: .year
            ),
            try .create(
                context: context,
                name: Calendar.utc.startOfMonth(for: date).stringValueWithoutLocale(.yyyyMM),
                type: .yearMonth
            ),
            try .create(
                context: context,
                name: content,
                type: .content
            ),
            try .create(
                context: context,
                name: group,
                type: .category
            )
        ]
    }

    func modify(balance: Decimal) {
        self.balance = balance
    }

    func modify(tags: [Tag]) {
        self.tags = tags
    }
}

extension Item {
    var profit: Decimal {
        income - outgo
    }

    var isProfitable: Bool {
        profit.isPlus
    }

    var year: Tag? {
        tags?.first {
            $0.type == .year
        }
    }

    var category: Tag? {
        tags?.first {
            $0.type == .category
        }
    }
}

extension Item: Comparable {
    static func < (lhs: Item, rhs: Item) -> Bool {
        lhs.date > rhs.date
    }
}

// MARK: - Test

extension Item {
    static func createIgnoringDuplicates(context: ModelContext,
                                         date: Date,
                                         content: String,
                                         income: Decimal,
                                         outgo: Decimal,
                                         group: String,
                                         repeatID: UUID) throws -> Item {
        let item = Item()
        context.insert(item)

        item.date = Calendar.utc.startOfDay(for: date)
        item.content = content
        item.income = income
        item.outgo = outgo
        item.repeatID = repeatID

        item.tags = [
            try .createIgnoringDuplicates(
                context: context,
                name: Calendar.utc.startOfYear(for: date).stringValueWithoutLocale(.yyyy),
                type: .year
            ),
            try .createIgnoringDuplicates(
                context: context,
                name: Calendar.utc.startOfMonth(for: date).stringValueWithoutLocale(.yyyyMM),
                type: .yearMonth
            ),
            try .createIgnoringDuplicates(
                context: context,
                name: content,
                type: .content
            ),
            try .createIgnoringDuplicates(
                context: context,
                name: group,
                type: .category
            )
        ]

        return item
    }
}
