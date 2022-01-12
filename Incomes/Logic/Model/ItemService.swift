//
//  ItemService.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/13.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import Foundation

struct ItemService {
    func groupByMonth(items: [Item]) -> [(Date, [Item])] {
        Dictionary(grouping: items) {
            Calendar.current.startOfMonth(for: $0.date)
        }.sorted {
            $0.key > $1.key
        }
    }

    func groupByContent(items: [Item]) -> [(String, [Item])] {
        Dictionary(grouping: items) {
            $0.content
        }.sorted {
            $0.key < $1.key
        }
    }
}
