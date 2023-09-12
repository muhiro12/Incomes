//
//  ItemFactory.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/13.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation

struct ItemFactory {
    // swiftlint:disable:next function_parameter_count)
    func callAsFunction(date: Date,
                        content: String,
                        income: Decimal,
                        outgo: Decimal,
                        group: String,
                        repeatID: UUID) -> Item {
        let item = Item()
        item.set(date: date,
                 content: content,
                 income: income,
                 outgo: outgo,
                 group: group,
                 repeatID: repeatID)
        return item
    }
}
