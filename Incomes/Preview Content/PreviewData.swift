//
//  PreviewData.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/26.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

struct PreviewData {
    static let listItem = ListItem(id: UUID(),
                                   date: Date(),
                                   content: .content,
                                   income: 999999,
                                   expenditure: 99999,
                                   balance: 9999999,
                                   group: .empty,
                                   repeatId: nil)

    static let listItems = ListItems(key: .all,
                                     value: [listItem, listItem])

    static let sectionItems = SectionItems(key: Date().year,
                                           value: [listItems])
}
