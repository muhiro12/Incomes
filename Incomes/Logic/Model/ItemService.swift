//
//  ItemService.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/13.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import Foundation
import CoreData

struct ItemService {
    private let repository: ItemRepository

    init(context: NSManagedObjectContext) {
        repository = .init(context: context)
    }

    // MARK: - Fetch

    func items(predicate: NSPredicate? = nil) throws -> [Item] {
        try repository.items(predicate: predicate)
    }

    // MARK: - Create

    func create(date: Date,
                content: String,
                income: NSDecimalNumber,
                outgo: NSDecimalNumber,
                group: String,
                repeatCount: Int = .one) throws {
        let repeatID = UUID()

        _ = repository.instantiate(date: date,
                                   content: content,
                                   income: income,
                                   outgo: outgo,
                                   group: group,
                                   repeatID: repeatID)

        for index in 0..<repeatCount {
            guard index > .zero else {
                continue
            }
            guard let repeatingDate = Calendar.current.date(byAdding: .month,
                                                            value: index,
                                                            to: date) else {
                assertionFailure()
                return
            }
            _ = repository.instantiate(date: repeatingDate,
                                       content: content,
                                       income: income,
                                       outgo: outgo,
                                       group: group,
                                       repeatID: repeatID)
        }

        try repository.save()
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
                 repeatID: item.repeatID)
        try repository.save()
    }

    func updateForRepeatingItems(item: Item, // swiftlint:disable:this function_parameter_count
                                 date: Date,
                                 content: String,
                                 income: NSDecimalNumber,
                                 outgo: NSDecimalNumber,
                                 group: String,
                                 predicate: NSPredicate) throws {
        let components = Calendar.current.dateComponents([.year, .month, .day],
                                                         from: item.date,
                                                         to: date)

        try items(predicate: predicate).forEach {
            guard let newDate = Calendar.current.date(byAdding: components, to: $0.date) else {
                assertionFailure()
                return
            }
            $0.set(date: newDate,
                   content: content,
                   income: income,
                   outgo: outgo,
                   group: group,
                   repeatID: item.repeatID)
        }

        try repository.save()
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
        try repository.delete(items: items)
    }

    func deleteAll() throws {
        try delete(items: items())
    }

    // MARK: - Calculate balance

    func recalculate() throws {
        try repository.recalculate()
    }

    // MARK: - Utilitiy

    static func groupByMonth(items: [Item]) -> [(month: Date, items: [Item])] {
        Dictionary(grouping: items) {
            Calendar.current.startOfMonth(for: $0.date)
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
