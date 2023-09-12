//
//  ItemRepository.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/13.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

struct ItemRepository: SwiftDataRepository {
    typealias Entity = Item

    let context: ModelContext
    let sortDescriptors: [SortDescriptor<Item>]

    init(context: ModelContext) {
        self.context = context
        self.sortDescriptors = Item.sortDescriptors()
    }
}
