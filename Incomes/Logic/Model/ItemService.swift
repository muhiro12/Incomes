//
//  ItemService.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/13.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

struct ItemService {
    private let repository: any Repository<Item>

    init(context: ModelContext) {
        self.repository = ItemRepository(context: context)
    }

    // MARK: - Fetch

    func items(predicate: Predicate<Item>? = nil) throws -> [Item] {
        try repository.fetchList(predicate: predicate)
    }

    // MARK: - Create

    func create(date: Date,
                content: String,
                income: Decimal,
                outgo: Decimal,
                group: String,
                repeatCount: Int = .one) throws {
        var items = [Item]()

        let repeatID = UUID()

        let item = Item(date: date,
                        content: content,
                        income: income,
                        outgo: outgo,
                        group: group,
                        repeatID: repeatID)
        items.append(item)

        for index in 0..<repeatCount {
            guard index > .zero else {
                continue
            }
            guard let repeatingDate = Calendar.utc.date(byAdding: .month,
                                                        value: index,
                                                        to: date) else {
                assertionFailure()
                return
            }
            let item = Item(date: repeatingDate,
                            content: content,
                            income: income,
                            outgo: outgo,
                            group: group,
                            repeatID: repeatID)
            items.append(item)
        }

        try repository.addList(items)
    }

    // MARK: - Update

    func update(item: Item, // swiftlint:disable:this function_parameter_count
                date: Date,
                content: String,
                income: Decimal,
                outgo: Decimal,
                group: String) throws {
        item.date = date
        item.content = content
        item.income = income
        item.outgo = outgo
        item.group = group
        item.repeatID = UUID()
        try repository.update(item)
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
        let items = try items(predicate: predicate)
        items.forEach {
            guard let newDate = Calendar.utc.date(byAdding: components, to: $0.date) else {
                assertionFailure()
                return
            }
            $0.date = newDate
            $0.content = content
            $0.income = income
            $0.outgo = outgo
            $0.group = group
            $0.repeatID = repeatID
        }

        try repository.updateList(items)
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

    // MARK: - Delete

    func delete(items: [Item]) throws {
        try repository.deleteList(items)
    }

    func deleteAll() throws {
        try delete(items: items())
    }

    // MARK: - Calculate balance

    func recalculate() throws {
        guard let item = try repository.fetchList().last else {
            return
        }
        try update(item: item,
                   date: item.date,
                   content: item.content,
                   income: item.income,
                   outgo: item.outgo,
                   group: item.group)
    }

    // MARK: - Utilitiy

    static func groupByYear(items: [Item]) -> [SectionedItems<Date>] {
        Dictionary(grouping: items) {
            Calendar.utc.startOfYear(for: $0.date)
        }.map {
            SectionedItems(section: $0.key, items: $0.value)
        }.sorted().reversed()
    }

    static func groupByMonth(items: [Item]) -> [SectionedItems<Date>] {
        Dictionary(grouping: items) {
            Calendar.utc.startOfMonth(for: $0.date)
        }.map {
            SectionedItems(section: $0.key, items: $0.value)
        }.sorted().reversed()
    }

    static func groupByGroup(items: [Item]) -> [SectionedItems<String>] {
        Dictionary(grouping: items) {
            $0.group
        }.map {
            SectionedItems(section: $0.key, items: $0.value)
        }.sorted()
    }

    static func groupByContent(items: [Item]) -> [SectionedItems<String>] {
        Dictionary(grouping: items) {
            $0.content
        }.map {
            SectionedItems(section: $0.key, items: $0.value)
        }.sorted()
    }
}
