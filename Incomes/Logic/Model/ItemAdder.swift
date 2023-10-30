//
//  ItemAdder.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/10/30.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

struct ItemAdder {
    private let repository: ItemRepository
    private let calculator: ItemBalanceCalculator
    private let factory: ItemFactory

    init(context: ModelContext) {
        self.repository = .init(context: context)
        self.calculator = .init(context: context)
        self.factory = .init(context: context)
    }

    func add(date: Date, // swiftlint:disable:this function_parameter_count
             content: String,
             income: Decimal,
             outgo: Decimal,
             group: String,
             repeatCount: Int) throws {
        var items = [Item]()

        let repeatID = UUID()

        let item = try factory(
            date: date,
            content: content,
            income: income,
            outgo: outgo,
            group: group,
            repeatID: repeatID
        )
        items.append(item)

        for index in 0..<repeatCount {
            guard index > .zero else {
                continue
            }
            guard let repeatingDate = Calendar.utc.date(byAdding: .month,
                                                        value: index,
                                                        to: date) else {
                assertionFailure()
                return
            }
            let item = try factory(
                date: repeatingDate,
                content: content,
                income: income,
                outgo: outgo,
                group: group,
                repeatID: repeatID
            )
            items.append(item)
        }

        try repository.addList(items)
        try calculator.calculate(for: items)
    }
}
