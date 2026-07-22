//
//  BalanceCalculator.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/14.
//

import Foundation
import SwiftData

/// Recalculates running balances for ordered items.
enum BalanceCalculator {
    struct CalculationInput: Equatable {
        let netIncome: Decimal
    }

    /// Recalculates balances starting from the earliest date covered by `items`.
    static func calculate(in context: ModelContext, for items: [Item]) throws {
        if let date = items.map(\.localDate).min() {
            try calculate(in: context, after: date)
        } else {
            try calculate(in: context, after: .distantPast)
        }
    }

    /// Recalculates balances for all items on or after `date`.
    static func calculate(in context: ModelContext, after date: Date) throws {
        let allItems = try context.fetch(.items(.all, order: .forward))

        guard let separatorIndex = allItems.firstIndex(where: { item in
            item.localDate >= date
        }) else {
            return
        }

        let previousBalance = allItems.prefix(upTo: separatorIndex).last?.balance ?? 0

        let targetList = allItems.suffix(from: separatorIndex)
        let balances = calculateBalances(
            startingFrom: previousBalance,
            inputs: targetList.map { item in
                .init(netIncome: item.netIncome)
            }
        )

        zip(targetList, balances).forEach { item, balance in
            item.modify(balance: balance)
        }
    }

    static func calculateBalances(
        startingFrom previousBalance: Decimal,
        inputs: [CalculationInput]
    ) -> [Decimal] {
        inputs.reduce(into: [Decimal]()) { result, input in
            let lastBalance = result.last ?? previousBalance
            result.append(lastBalance + input.netIncome)
        }
    }
}
