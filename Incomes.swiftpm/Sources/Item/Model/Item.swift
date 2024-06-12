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

        item.tags = try TagService(context: context).createTags(date: date, content: content, group: group)

        return item
    }

    func modify(date: Date,
                content: String,
                income: Decimal,
                outgo: Decimal,
                group: String) throws {
        self.date = Calendar.utc.startOfDay(for: date)
        self.content = content
        self.income = income
        self.outgo = outgo
        self.repeatID = UUID()

        guard let context = modelContext else {
            return
        }

        self.tags = try TagService(context: context).createTags(date: date, content: content, group: group)

        try context.save()
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

    @available(*, deprecated)
    func modify(date: Date,
                content: String,
                income: Decimal,
                outgo: Decimal,
                group: String,
                repeatID: UUID) {
        self.date = Calendar.utc.startOfDay(for: date)
        self.content = content
        self.income = income
        self.outgo = outgo
        self.repeatID = repeatID
    }

    @available(*, deprecated)
    func modify(balance: Decimal) {
        self.balance = balance
    }
}

extension Item: Identifiable {}
