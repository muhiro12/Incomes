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
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func calculate(for items: [Item]) throws {
        if let date = items.map({ $0.date }).min() {
            try calculate(after: date)
        } else {
            try calculateAll()
        }
    }

    func calculate(after date: Date) throws {
        try context.save()

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
            item.set(balance: balance)
            resultList.append(item)
        }

        try context.save()
    }

    func calculateAll() throws {
        try calculate(after: .init(timeIntervalSince1970: .zero))
    }
}
