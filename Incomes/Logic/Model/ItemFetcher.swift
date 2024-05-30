//
//  ItemFetcher.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/10/30.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

struct ItemFetcher {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetch(predicate: Predicate<Item>?) throws -> [Item] {
        try context.fetch(.init(predicate: predicate, sortBy: Item.sortDescriptors()))
    }

    func fetchCount(predicate: Predicate<Item>?) throws -> Int {
        try context.fetchCount(.init(predicate: predicate))
    }
}
