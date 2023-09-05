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

        try calculate(after: oldestDate)
    }

    func calculate(after date: Date) throws {
        let allItems = try context.fetch(.init(sortBy: Item.sortDescriptors())).reversed()

        guard let separatorIndex = allItems.firstIndex(where: { $0.date >= date }) else {
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
            item.set(order: .zero, balance: balance)
            resultList.append(item)
        }

        try context.save()
    }
}
