//
//  ItemService.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2022/01/13.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import Foundation

struct ItemService {
    func groupByMonth(items: [Item]) -> [(month: Date, items: [Item])] {
        Dictionary(grouping: items) {
            Calendar.current.startOfMonth(for: $0.date)
        }.map {
            (month: $0.0, items: $0.1)
        }.sorted {
            $0.month > $1.month
        }
    }

    func groupByContent(items: [Item]) -> [(content: String, items: [Item])] {
        Dictionary(grouping: items) {
            $0.content
        }.map {
            (content: $0.0, items: $0.1)
        }.sorted {
            $0.content < $1.content
        }
    }
}
