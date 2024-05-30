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
    private(set) var tags: [Tag]? // swiftlint:disable:this discouraged_optional_collection

    // TODO: Remove(2024/04~) // swiftlint:disable:this todo
    private(set) var group = String.empty
    private(set) var startOfYear = Date(timeIntervalSinceReferenceDate: .zero)

    private init() {}

    static func create(context: ModelContext, // swiftlint:disable:this function_parameter_count
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

        // TODO: Remove(2024/04~) // swiftlint:disable:this todo
        item.group = group
        item.startOfYear = Calendar.utc.startOfYear(for: date)

        let tagService = TagService(context: context)
        item.tags = [
            try tagService.create(
                name: Calendar.utc.startOfYear(for: date).stringValueWithoutLocale(.yyyy),
                type: .year
            ),
            try tagService.create(
                name: Calendar.utc.startOfMonth(for: date).stringValueWithoutLocale(.yyyyMM),
                type: .yearMonth
            ),
            try tagService.create(
                name: content,
                type: .content
            ),
            try tagService.create(
                name: group,
                type: .category
            )
        ]

        return item
    }

    func update(date: Date,
                content: String,
                income: Decimal,
                outgo: Decimal,
                group: String) throws {
        self.date = Calendar.utc.startOfDay(for: date)
        self.content = content
        self.income = income
        self.outgo = outgo
        self.repeatID = UUID()

        // TODO: Remove(2024/04~) // swiftlint:disable:this todo
        self.group = group
        self.startOfYear = Calendar.utc.startOfYear(for: date)

        guard let context = modelContext else {
            return
        }

        let tagService = TagService(context: context)
        self.tags = [
            try tagService.create(
                name: Calendar.utc.startOfYear(for: date).stringValueWithoutLocale(.yyyy),
                type: .year
            ),
            try tagService.create(
                name: Calendar.utc.startOfMonth(for: date).stringValueWithoutLocale(.yyyyMM),
                type: .yearMonth
            ),
            try tagService.create(
                name: content,
                type: .content
            ),
            try tagService.create(
                name: group,
                type: .category
            )
        ]

        try context.save()
    }

    func update(tags: [Tag]) {
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
    func update(date: Date, // swiftlint:disable:this function_parameter_count
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

        self.group = group
        self.startOfYear = Calendar.utc.startOfYear(for: date)
    }

    @available(*, deprecated)
    func update(balance: Decimal) {
        self.balance = balance
    }
}

extension Item: Identifiable {}
