//
//  HomeListItemsPerYear.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

struct HomeListItemsPerYear: Identifiable {
    let id = UUID()
    let year: String
    let listItems: [HomeListItem]
}
