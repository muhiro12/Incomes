//
//  BalanceCalculator.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/14.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import Foundation
import CoreData

struct BalanceCalculator {
    let context: NSManagedObjectContext

    func calculate() throws {
        let repository = ItemRepository(context: context)

        let editedItems = [
            context.insertedObjects,
            context.updatedObjects
        ].flatMap {
            $0.compactMap { $0 as? Item }
        }
        guard let oldestDate = editedItems.sorted(by: { $0.date < $1.date }).first?.date else {
            return
        }

        try context.save()

        let allItems = try repository.items().reversed() as [Item]
        let items = try repository.items(predicate: .init(dateIsAfter: oldestDate)).reversed() as [Item]

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
        let repository = ItemRepository(context: context)

        try context.save()

        let items = try repository.items().reversed() as [Item]

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
