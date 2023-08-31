//
//  Item.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

@Model final class Item {
    var date = Date(timeIntervalSinceReferenceDate: .zero)
    var content = String.empty
    var income = Decimal.zero
    var outgo = Decimal.zero
    var balance = Decimal.zero
    var group = String.empty
    var repeatID = UUID()

    init(date: Date,
         content: String,
         income: Decimal,
         outgo: Decimal,
         group: String,
         repeatID: UUID) {
        self.date = Calendar.utc.startOfDay(for: date)
        self.content = content
        self.income = income
        self.outgo = outgo
        self.group = group
        self.repeatID = repeatID
    }
}

extension Item {
    var profit: Decimal {
        income - outgo
    }

    var isProfitable: Bool {
        profit.isPlus
    }
}
