//
//  ItemController.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/13.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation
import CoreData

struct ItemController { // swiftlint:disable function_parameter_count
    let context: NSManagedObjectContext

    // MARK: - Fetch

    func items(predicate: NSPredicate? = nil) throws -> [Item] {
        let request = Item.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.date, ascending: true)]
        return try context.fetch(request)
    }

    // MARK: - Create

    func create(date: Date,
                content: String,
                income: NSDecimalNumber,
                outgo: NSDecimalNumber,
                group: String,
                repeatCount: Int = .one) throws {
        let item = Item(context: context)
        item.set(date: date,
                 content: content,
                 income: income,
                 outgo: outgo,
                 group: group,
                 repeatID: UUID())

        for index in 0..<repeatCount {
            guard index > .zero else {
                continue
            }
            guard let repeatingDate = Calendar.current.date(byAdding: .month,
                                                            value: index,
                                                            to: item.date) else {
                assertionFailure()
                return
            }
            let repeatingItem = Item(context: context)
            repeatingItem.set(date: repeatingDate,
                              content: content,
                              income: income,
                              outgo: outgo,
                              group: group,
                              repeatID: item.repeatID)
        }

        try saveAll()
    }

    // MARK: - Save

    func save() throws {
        try context.save()
    }

    func saveAll() throws {
        try calculateForFutureItem()
    }

    // MARK: - Update

    func update(item: Item,
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
        try saveAll()
    }

    func updateForRepeatingItems(item: Item,
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

        try saveAll()
    }

    func updateForFutureItems(item: Item,
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

    func updateForAllItems(item: Item,
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

    func delete(item: Item) {
        context.delete(item)
    }

    func delete(items: [Item]) {
        items.forEach {
            delete(item: $0)
        }
    }

    func deleteAll() throws {
        delete(items: try items())
    }

    // MARK: - Calculate balance

    func calculate(predicate: NSPredicate? = nil)  throws {
        let items = try items(predicate: predicate)
        items.forEach { _ in
            guard false else {
                return
            }
        }
        for tuple in items.enumerated() {
            let index = tuple.offset
            let item = tuple.element

            if index == .zero {
                item.balance = item.balance.adding(item.profit)
            } else {
                item.balance = items[index - 1].balance.adding(item.profit)
            }
        }
        try save()
    }

    func calculateForFutureItem() throws {
        let items = context.registeredObjects.compactMap { $0 as? Item }
        guard let oldest = items.sorted(by: { $0.date < $1.date }).first else {
            return
        }
        try calculate(predicate: .init(dateIsAfter: oldest.date))
    }
}
