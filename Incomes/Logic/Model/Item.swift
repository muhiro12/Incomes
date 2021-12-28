//
//  Item.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/28.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import Foundation

extension Item {
    convenience init(date: Date, content: String, income: Decimal, outgo: Decimal, group: String, repeatID: UUID) {
        self.init()
        self.date = date
        self.content = content
        self.income = income.asNSDecimalNumber
        self.outgo = outgo.asNSDecimalNumber
        self.group = group
        self.repeatId = repeatID
    }

    var profit: Decimal {
        income.decimal - outgo.decimal
    }

    var isProfitable: Bool {
        profit > 0
    }
}
