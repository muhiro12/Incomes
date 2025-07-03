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

    @MainActor
    static func create(container: ModelContainer,
                       date: Date,
                       content: String,
                       income: Decimal,
                       outgo: Decimal,
                       category: String,
                       repeatID: UUID) throws -> Item {
        let item = Item()
        container.mainContext.insert(item)

        item.date = Calendar.utc.startOfDay(for: Calendar.utc.shiftedDate(componentsFrom: date, in: .current))
        item.content = content
        item.income = income
        item.outgo = outgo
        item.repeatID = repeatID

        item.tags = [
            try .create(
                container: container,
                name: date.stringValueWithoutLocale(.yyyy),
                type: .year
            ),
            try .create(
                container: container,
                name: date.stringValueWithoutLocale(.yyyyMM),
                type: .yearMonth
            ),
            try .create(
                container: container,
                name: content,
                type: .content
            ),
            try .create(
                container: container,
                name: category,
                type: .category
            )
        ]

        return item
    }

    @MainActor
    func modify(date: Date,
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
                container: context.container,
                name: date.stringValueWithoutLocale(.yyyy),
                type: .year
            ),
            try .create(
                container: context.container,
                name: date.stringValueWithoutLocale(.yyyyMM),
                type: .yearMonth
            ),
            try .create(
                container: context.container,
                name: content,
                type: .content
            ),
            try .create(
                container: context.container,
                name: category,
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
    var utcDate: Date {
        date
    }

    var localDate: Date {
        Calendar.current.shiftedDate(componentsFrom: utcDate, in: .utc)
    }

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
        lhs.utcDate > rhs.utcDate
    }
}

// MARK: - Test

extension Item {
    @MainActor
    static func createIgnoringDuplicates(container: ModelContainer,
                                         date: Date,
                                         content: String,
                                         income: Decimal,
                                         outgo: Decimal,
                                         category: String,
                                         repeatID: UUID) throws -> Item {
        let item = Item()
        container.mainContext.insert(item)

        item.date = Calendar.utc.startOfDay(for: Calendar.utc.shiftedDate(componentsFrom: date, in: .current))
        item.content = content
        item.income = income
        item.outgo = outgo
        item.repeatID = repeatID

        item.tags = [
            try .createIgnoringDuplicates(
                container: container,
                name: date.stringValueWithoutLocale(.yyyy),
                type: .year
            ),
            try .createIgnoringDuplicates(
                container: container,
                name: date.stringValueWithoutLocale(.yyyyMM),
                type: .yearMonth
            ),
            try .createIgnoringDuplicates(
                container: container,
                name: content,
                type: .content
            ),
            try .createIgnoringDuplicates(
                container: container,
                name: category,
                type: .category
            )
        ]

        return item
    }
}
