//
//  SectionItems.swift
//  Clarify
//
//  Created by Hiromu Nakano on 2020/04/14.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

struct SectionItems: Identifiable {
    var id = UUID()

    let key: String
    let value: [ListItems]
}
