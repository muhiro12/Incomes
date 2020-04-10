//
//  HomeListItem.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

struct HomeListItem: Identifiable {
    let id = UUID()
    var item: Item?

    let date: Date
    let content: String
    let income: Int
    let expenditure: Int
    let balance: Int
}
