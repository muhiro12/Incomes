//
//  ItemService.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/13.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import CoreData
import Foundation

struct ItemService {
    private let context: NSManagedObjectContext
    private let repository: any Repository<Item>

    init(context: NSManagedObjectContext) {
        self.context = context
        self.repository = ItemRepository(context: context)
    }

    // MARK: - Fetch

    func items(predicate: NSPredicate? = nil) throws -> [Item] {
        try repository.fetchList(predicate: predicate)
    }

    // MARK: - Create

    func create(date: Date,
                content: String,
                income: NSDecimalNumber,
                outgo: NSDecimalNumber,
                group: String,
                repeatCount: Int = .one) throws {
        var items = [Item]()

        let repeatID = UUID()

        let item = Item(context: context)
        item.set(date: date,
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
            let item = Item(context: context)
            item.set(date: repeatingDate,
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
                income: NSDecimalNumber,
                outgo: NSDecimalNumber,
                group: String) throws {
        item.set(date: date,
                 content: content,
                 income: income,
                 outgo: outgo,
                 group: group,
                 repeatID: UUID())
        try repository.update(item)
    }

    func updateForRepeatingItems(item: Item, // swiftlint:disable:this function_parameter_count
                                 date: Date,
                                 content: String,
                                 income: NSDecimalNumber,
                                 outgo: NSDecimalNumber,
                                 group: String,
                                 predicate: NSPredicate) throws {
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
            $0.set(date: newDate,
                   content: content,
                   income: income,
                   outgo: outgo,
                   group: group,
                   repeatID: repeatID)
        }

        try repository.updateList(items)
    }

    func updateForFutureItems(item: Item, // swiftlint:disable:this function_parameter_count
                              date: Date,
                              content: String,
                              income: NSDecimalNumber,
                              outgo: NSDecimalNumber,
                              group: String) throws {
        try updateForRepeatingItems(item: item,
                                    date: date,
                                    content: content,
                                    income: income,
                                    outgo: outgo,
                                    group: group,
                                    predicate: .init(repeatIDIs: item.repeatID, dateIsAfter: item.date))
    }

    func updateForAllItems(item: Item, // swiftlint:disable:this function_parameter_count
                           date: Date,
                           content: String,
                           income: NSDecimalNumber,
                           outgo: NSDecimalNumber,
                           group: String) throws {
        try updateForRepeatingItems(item: item,
                                    date: date,
                                    content: content,
                                    income: income,
                                    outgo: outgo,
                                    group: group,
                                    predicate: .init(repeatIDIs: item.repeatID))
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

    static func groupByMonth(items: [Item]) -> [(month: Date, items: [Item])] {
        Dictionary(grouping: items) {
            Calendar.utc.startOfMonth(for: $0.date)
        }.map {
            (month: $0.0, items: $0.1)
        }.sorted {
            $0.month > $1.month
        }
    }

    static func groupByContent(items: [Item]) -> [(content: String, items: [Item])] {
        Dictionary(grouping: items) {
            $0.content
        }.map {
            (content: $0.0, items: $0.1)
        }.sorted {
            $0.content < $1.content
        }
    }
}
