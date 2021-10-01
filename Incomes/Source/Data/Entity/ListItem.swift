//
//  ListItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

struct ListItem: Identifiable {
    let id = UUID()

    let date: Date
    let content: String
    let group: String
    let income: Decimal
    let expenditure: Decimal

    var balance: Decimal = .zero
    var original: Item?
}

extension ListItem {
    var profit: Decimal {
        return income - expenditure
    }

    var isProfitable: Bool {
        return profit > 0
    }
}
