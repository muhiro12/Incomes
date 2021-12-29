//
//  Repository.swift
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
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: .item)
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.date, ascending: true)]
        return try context.fetch(request) as? [Item] ?? []
    }

    // MARK: - Create

    func create(item: Item,
                repeatCount: Int = .one) throws {
        for index in 0..<repeatCount {
            guard index > .zero else {
                break
            }
            guard let date = Calendar.current.date(byAdding: .month,
                                                   value: index,
                                                   to: item.date) else {
                assertionFailure()
                return
            }
            _ = Item(context: context).set(date: date,
                                           content: item.content,
                                           income: item.income,
                                           outgo: item.outgo,
                                           group: item.group,
                                           repeatID: item.repeatId)
        }
        try saveAll()
    }

    // MARK: - Save

    func saveAll() throws {
        try context.save()
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
            _ = $0.set(date: newDate,
                       content: edited.content,
                       income: edited.income,
                       outgo: edited.outgo,
                       group: edited.group,
                       repeatID: edited.repeatId)
        }

        try saveAll()
    }

    func saveForAllItems(edited: Item, oldDate: Date) throws {
        try saveForRepeatingItems(edited: edited,
                                  oldDate: oldDate,
                                  predicate: .init(repeatIDFor: edited.repeatId))
    }

    func saveForFutureItems(edited: Item, oldDate: Date) throws {
        try saveForRepeatingItems(edited: edited,
                                  oldDate: oldDate,
                                  predicate: .init(repeatIDAndFutureFor: edited.repeatId, oldDate: oldDate))
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
}