//
//  Item.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Item {
    private(set) var date = Date(timeIntervalSinceReferenceDate: .zero)
    private(set) var content = String.empty
    private(set) var income = Decimal.zero
    private(set) var outgo = Decimal.zero
    private(set) var repeatID = UUID()
    private(set) var balance = Decimal.zero

    @Relationship(inverse: \Tag.items)
    private(set) var tags: [Tag]?

    // TODO: Remove
    private(set) var group = String.empty
    private(set) var startOfYear = Date(timeIntervalSinceReferenceDate: .zero)

    init(date: Date,
         content: String,
         income: Decimal,
         outgo: Decimal,
         group: String,
         repeatID: UUID) {
        set(date: date,
            content: content,
            income: income,
            outgo: outgo,
            group: group,
            repeatID: repeatID)
    }
}

extension Item {
    var profit: Decimal {
        income - outgo
    }

    var isProfitable: Bool {
        profit.isPlus
    }

    func set(date: Date, // swiftlint:disable:this function_parameter_count
             content: String,
             income: Decimal,
             outgo: Decimal,
             group: String,
             repeatID: UUID) {
        self.date = Calendar.utc.startOfDay(for: date)
        self.content = content
        self.income = income
        self.outgo = outgo
        self.repeatID = repeatID

        self.tags = [
            // TODO: Add tags
        ]

        // TODO: Remove
        self.group = group
        self.startOfYear = Calendar.utc.startOfYear(for: date)
    }

    func set(balance: Decimal) {
        self.balance = balance
    }

    func set(tags: [Tag]) {
        self.tags = tags
    }
}
