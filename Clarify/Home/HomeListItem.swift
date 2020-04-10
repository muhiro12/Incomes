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
    let item: Item
    let balance: Int
}
