//
//  ListItem.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

struct ListItem: Identifiable {
    let id: UUID
    var original: Item?

    let date: Date
    let content: String
    let income: Int
    let expenditure: Int
    let balance: Int
}
