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
    private let repository: ItemRepository

    init(context: ModelContext) {
        self.repository = .init(context: context)
    }

    func fetch(predicate: Predicate<Item>?) throws -> [Item] {
        try repository.fetchList(predicate: predicate)
    }

    func fetchCount(predicate: Predicate<Item>?) throws -> Int {
        try repository.fetchCount(predicate: predicate)
    }
}
