//
//  ItemFactory.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/13.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

struct ItemFactory {
    let context: ModelContext

    func callAsFunction(date: Date, // swiftlint:disable:this function_parameter_count
                        content: String,
                        income: Decimal,
                        outgo: Decimal,
                        group: String,
                        repeatID: UUID) throws -> Item {
        let item = Item()
        context.insert(item)

        item.set(date: date,
                 content: content,
                 income: income,
                 outgo: outgo,
                 group: group,
                 repeatID: repeatID)

        let tagFactory = TagFactory(context: context)
        item.set(tags: [
            try tagFactory(Calendar.utc.startOfYear(for: date).stringValueWithoutLocale(.yyyy), for: .year),
            try tagFactory(Calendar.utc.startOfMonth(for: date).stringValueWithoutLocale(.yyyyMM), for: .yearMonth),
            try tagFactory(content, for: .content),
            try tagFactory(group, for: .category)
        ])

        return item
    }
}
