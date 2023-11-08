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
    private let context: ModelContext
    private let tagFactory: TagFactory

    init(context: ModelContext) {
        self.context = context
        self.tagFactory = .init(context: context)
    }

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
        item.set(tags: try tagFactory.tags(date: date, content: content, group: group))

        return item
    }
}
