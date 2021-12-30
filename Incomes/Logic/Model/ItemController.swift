//
//  ItemController.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/13.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation
import CoreData

struct ItemController {
    let context: NSManagedObjectContext

    // MARK: - Fetch

    func items(predicate: NSPredicate? = nil) throws -> [Item] {
        let request = Item.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.date, ascending: true)]
        return try context.fetch(request)
    }

    // MARK: - Create

    func create(item: Item,
                repeatCount: Int = .one) throws {
        for index in 0..<repeatCount {
            guard index > .zero else {
                continue
            }
            guard let date = Calendar.current.date(byAdding: .month,
                                                   value: index,
                                                   to: item.date) else {
                assertionFailure()
                return
            }
            Item(context: context)
                .set(date: date,
                     content: item.content,
                     income: item.income,
                     outgo: item.outgo,
                     group: item.group)
                .repeatID = item.repeatID
        }
        try saveAll()
    }

    // MARK: - Save

    func save() throws {
        try context.save()
    }

    func saveAll() throws {
        try calcurateForFutureItem()
    }

    func saveForRepeatingItems(edited: Item, oldDate: Date, predicate: NSPredicate) throws {
        let components = Calendar.current.dateComponents([.year, .month, .day],
                                                         from: oldDate,
                                                         to: edited.date)

        try items(predicate: predicate).forEach {
            guard let newDate = Calendar.current.date(byAdding: components, to: $0.date) else {
                assertionFailure()
                return
            }
            $0.set(date: newDate,
                   content: edited.content,
                   income: edited.income,
                   outgo: edited.outgo,
                   group: edited.group)
                .repeatID = edited.repeatID
        }

        try saveAll()
    }

    func saveForAllItems(edited: Item, oldDate: Date) throws {
        try saveForRepeatingItems(edited: edited,
                                  oldDate: oldDate,
                                  predicate: .init(repeatIDIs: edited.repeatID))
    }

    func saveForFutureItems(edited: Item, oldDate: Date) throws {
        try saveForRepeatingItems(edited: edited,
                                  oldDate: oldDate,
                                  predicate: .init(repeatIDIs: edited.repeatID, dateIsAfter: oldDate))
    }

    // MARK: - Delete

    func delete(item: Item) {
        context.delete(item)
    }

    func deleteAll() throws {
        try items().forEach {
            delete(item: $0)
        }
    }

    // MARK: - Calcurate

    func calcurate(predicate: NSPredicate? = nil)  throws {
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
                item.balance.adding(item.profit)
            } else {
                item.balance = items[index - 1].balance.adding(item.profit)
            }
        }
        try save()
    }

    func calcurateForFutureItem() throws {
        let items = context.registeredObjects.compactMap { $0 as? Item }
        guard let oldest = items.sorted(by: { $0.date < $1.date }).first else {
            return
        }
        try calcurate(predicate: .init(dateIsAfter: oldest.date))
    }
}
