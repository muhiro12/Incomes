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
    let repository: any Repository<Item>

    func calculate() throws {
        let editedDateList = [
            context.insertedObjects,
            context.updatedObjects,
            context.deletedObjects
        ].flatMap {
            $0.compactMap { ($0 as? Item)?.date }
        }

        try context.save()

        guard let oldestDate = editedDateList.sorted().first else {
            return
        }

        let allItems = try repository.fetchList().reversed()

        guard let separatorIndex = allItems.firstIndex(where: { $0.date >= oldestDate }) else {
            return
        }

        let previousBalance = allItems.prefix(upTo: separatorIndex).last?.balance ?? 0

        let targetList = allItems.suffix(from: separatorIndex)
        var resultList = [Item]()

        targetList.enumerated().forEach { index, item in
            item.balance = {
                if index == 0 {
                    return previousBalance.adding(item.profit)
                } else {
                    return resultList[index - 1].balance.adding(item.profit)
                }
            }()
            resultList.append(item)
        }

        try context.save()
    }

    func recalculate()  throws {
        try context.save()

        let items = try repository.fetchList().reversed() as [Item]

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
