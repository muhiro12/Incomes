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
        let balances = try calculateBalances(
            startingFrom: previousBalance,
            inputs: try targetList.map { item in
                .init(netIncome: try netIncome(income: item.income, outgo: item.outgo))
            }
        )

        zip(targetList, balances).forEach { item, balance in
            item.modify(balance: balance)
        }
    }

    static func calculateBalances(
        startingFrom previousBalance: Decimal,
        inputs: [CalculationInput]
    ) throws -> [Decimal] {
        try inputs.reduce(into: [Decimal]()) { result, input in
            var lastBalance = result.last ?? previousBalance
            var netIncome = input.netIncome
            var balance = Decimal.zero
            let error = NSDecimalAdd(&balance, &lastBalance, &netIncome, .plain)
            guard error == .noError,
                  AmountPrecision.isExactlyStorable(balance),
                  balance - lastBalance == netIncome,
                  balance - netIncome == lastBalance else {
                throw ItemAmountError.balanceOutOfRange
            }
            result.append(balance)
        }
    }

    /// Checks subtraction before an already-rounded net income can hide lost digits.
    static func netIncome(income: Decimal, outgo: Decimal) throws -> Decimal {
        var income = income
        var outgo = outgo
        var result = Decimal.zero
        // Subtraction can report no error after dropping a small operand.
        // Check both inverse relations as well as Foundation's status.
        guard NSDecimalSubtract(&result, &income, &outgo, .plain) == .noError,
              !result.isNaN,
              result + outgo == income,
              income - result == outgo else {
            throw ItemAmountError.balanceOutOfRange
        }
        return result
    }
}
