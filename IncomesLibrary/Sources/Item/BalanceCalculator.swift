//
//  BalanceCalculator.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/14.
//

import Foundation
import SwiftData

/// Recalculates running balances for ordered items.
public enum BalanceCalculator {
    /// Recalculates balances starting from the earliest date covered by `items`.
    public static func calculate(in context: ModelContext, for items: [Item]) throws {
        if let date = items.map(\.localDate).min() {
            try calculate(in: context, after: date)
        } else {
            try calculate(in: context, after: .distantPast)
        }
    }

    /// Recalculates balances for all items on or after `date`.
    public static func calculate(in context: ModelContext, after date: Date) throws {
        let allItems = try context.fetch(.items(.all, order: .forward))

        guard let separatorIndex = allItems.firstIndex(where: { item in
            item.localDate >= date
        }) else {
            return
        }

        let previousBalance = allItems.prefix(upTo: separatorIndex).last?.balance ?? 0

        let targetList = allItems.suffix(from: separatorIndex)
        var resultList = [Item]()

        targetList.enumerated().forEach { index, item in
            let balance = {
                guard resultList.indices.contains(index - 1) else {
                    return previousBalance + item.netIncome
                }
                return resultList[index - 1].balance + item.netIncome
            }()
            item.modify(balance: balance)
            resultList.append(item)
        }
    }
}
