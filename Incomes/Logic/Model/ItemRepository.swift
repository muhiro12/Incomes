//
//  ItemRepository.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/13.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation
import CoreData

struct ItemRepository {
    let context: NSManagedObjectContext

    // MARK: - Fetch

    func items(predicate: NSPredicate? = nil) throws -> [Item] {
        let request = Item.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = NSSortDescriptor.standards
        return try context.fetch(request)
    }

    // MARK: - Insert

    func insert(items: [Item]) throws {
        items.forEach {
            context.insert($0)
        }
        try calculate()
    }

    // MARK: - Update

    func update() throws {
        try calculate()
    }

    // MARK: - Delete

    func delete(items: [Item]) throws {
        items.forEach {
            context.delete($0)
        }
        try calculate()
    }

    func deleteAll() {
        context.refreshAllObjects()
    }

    // MARK: - Calculate balance

    func calculate() throws {
        let editedItems = [
            context.insertedObjects,
            context.updatedObjects
        ].flatMap {
            $0.compactMap { $0 as? Item }
        }
        guard let oldest = editedItems.sorted(by: { $0.date < $1.date }).first else {
            return
        }
        try context.save()
        let allItems = try self.items().reversed() as [Item]
        let items = try items(predicate: .init(dateIsAfter: oldest.date)).reversed() as [Item]
        for tuple in items.enumerated() {
            let index = tuple.offset
            let item = tuple.element

            item.balance = {
                if items.indices.contains(index - 1) {
                    return items[index - 1].balance.adding(item.profit)
                } else if let index = allItems.firstIndex(of: item),
                          allItems.indices.contains(index - 1) {
                    return allItems[index - 1].balance.adding(item.profit)
                } else {
                    return item.profit
                }
            }()
        }
        try context.save()
    }

    func recalculate()  throws {
        try context.save()
        let items = try items().reversed() as [Item]
        for tuple in items.enumerated() {
            let index = tuple.offset
            let item = tuple.element

            item.balance = {
                if items.indices.contains(index - 1) {
                    return items[index - 1].balance.adding(item.profit)
                } else {
                    return item.profit
                }
            }()
        }
        try context.save()
    }
}
