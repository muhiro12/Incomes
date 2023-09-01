//
//  BalanceCalculator.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/14.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

struct BalanceCalculator {
    let context: ModelContext
    let repository: any Repository<Item>

    func calculate() throws {
        let editedDateList = [
            context.insertedModelsArray,
            context.changedModelsArray,
            context.deletedModelsArray
        ].flatMap {
            $0.compactMap { ($0 as? Item)?.date }
        }

        try context.save()

        guard let oldestDate = editedDateList.min() else {
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
            let balance = {
                guard resultList.indices.contains(index - 1) else {
                    return previousBalance + item.profit
                }
                return resultList[index - 1].balance + item.profit
            }()
            item.set(balance: balance)
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

            let balance = {
                guard items.indices.contains(index - 1) else {
                    return item.profit
                }
                return items[index - 1].balance + item.profit
            }()
            item.set(balance: balance)
        }

        try context.save()
    }
}
