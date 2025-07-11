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
    func calculate(in context: ModelContext, for items: [Item]) throws {
        if let date = items.map(\.localDate).min() {
            try calculate(in: context, after: date)
        } else {
            try calculate(in: context, after: .distantPast)
        }
    }

    func calculate(in context: ModelContext, after date: Date) throws {
        let allItems = try context.fetch(.items(.all, order: .forward))

        guard let separatorIndex = allItems.firstIndex(where: { $0.localDate >= date }) else {
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
            item.modify(balance: balance)
            resultList.append(item)
        }
    }
}
