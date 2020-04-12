//
//  ListItems.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/10.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

struct ListItems: Identifiable {
    let id = UUID()
    var key: String?
    let value: [ListItem]
}
