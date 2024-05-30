//
//  ItemUpdater.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/10/30.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

struct ItemUpdater {
    private let context: ModelContext
    private let calculator: ItemBalanceCalculator
    private let tagFactory: TagFactory

    init(context: ModelContext) {
        self.context = context
        self.calculator = .init(context: context)
        self.tagFactory = .init(context: context)
    }

    func update(items: [Item]) throws {
        try context.save()
        try calculator.calculate(for: items)
    }

    func update(item: Item, // swiftlint:disable:this function_parameter_count
                date: Date,
                content: String,
                income: Decimal,
                outgo: Decimal,
                group: String) throws {
        item.set(date: date,
                 content: content,
                 income: income,
                 outgo: outgo,
                 group: group,
                 repeatID: UUID())
        item.set(tags: try tagFactory.tags(date: date, content: content, group: group))
        try update(items: [item])
    }

    func updateForRepeatingItems(item: Item, // swiftlint:disable:this function_parameter_count
                                 date: Date,
                                 content: String,
                                 income: Decimal,
                                 outgo: Decimal,
                                 group: String,
                                 predicate: Predicate<Item>) throws {
        let components = Calendar.utc.dateComponents([.year, .month, .day],
                                                     from: item.date,
                                                     to: date)

        let repeatID = UUID()
        let items = try context.fetch(.init(predicate: predicate, sortBy: Item.sortDescriptors()))
        try items.forEach {
            guard let newDate = Calendar.utc.date(byAdding: components, to: $0.date) else {
                assertionFailure()
                return
            }
            $0.set(date: newDate,
                   content: content,
                   income: income,
                   outgo: outgo,
                   group: group,
                   repeatID: repeatID)
            item.set(tags: try tagFactory.tags(date: newDate, content: content, group: group))
        }

        try update(items: items)
    }

    func updateForFutureItems(item: Item, // swiftlint:disable:this function_parameter_count
                              date: Date,
                              content: String,
                              income: Decimal,
                              outgo: Decimal,
                              group: String) throws {
        try updateForRepeatingItems(item: item,
                                    date: date,
                                    content: content,
                                    income: income,
                                    outgo: outgo,
                                    group: group,
                                    predicate: Item.predicate(repeatIDIs: item.repeatID, dateIsAfter: item.date))
    }

    func updateForAllItems(item: Item, // swiftlint:disable:this function_parameter_count
                           date: Date,
                           content: String,
                           income: Decimal,
                           outgo: Decimal,
                           group: String) throws {
        try updateForRepeatingItems(item: item,
                                    date: date,
                                    content: content,
                                    income: income,
                                    outgo: outgo,
                                    group: group,
                                    predicate: Item.predicate(repeatIDIs: item.repeatID))
    }
}
