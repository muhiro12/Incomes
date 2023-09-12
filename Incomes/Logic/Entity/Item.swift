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

    // swiftlint:disable:next line_length
    init(date: Date = Date(timeIntervalSinceReferenceDate: .zero), content: String = String.empty, income: Decimal = Decimal.zero, outgo: Decimal = Decimal.zero, repeatID: UUID = UUID(), balance: Decimal = Decimal.zero, tags: [Tag]? = nil, group: String = String.empty, startOfYear: Date = Date(timeIntervalSinceReferenceDate: .zero)) {
        self.date = date
        self.content = content
        self.income = income
        self.outgo = outgo
        self.repeatID = repeatID
        self.balance = balance
        self.tags = tags
        self.group = group
        self.startOfYear = startOfYear
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
