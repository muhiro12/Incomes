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

    let key: String
    let value: [ListItem]

    init(key: String, value: [ListItem]) {
        self.key = key
        self.value = value
    }

    init(from items: [Item]) {
        var listItems: [ListItem] = []

        for index in 0..<items.count {
            let item = items[index]

            var balance = 0
            if listItems.count > 0 {
                balance += listItems[index - 1].balance
            }
            balance += Int(item.income - item.expenditure)

            if let date = item.date,
                let content = item.content {
                let listItem = ListItem(id: UUID(),
                                        original: item,
                                        date: date,
                                        content: content,
                                        income: Int(item.income),
                                        expenditure: Int(item.expenditure),
                                        balance: balance)
                listItems.append(listItem)
            }
        }

        self.init(key: "All", value: listItems.reversed())
    }

    func grouped(by keyForValue: (ListItem) -> String) -> [Self] {
        var listItemsArray: [ListItems] = []

        let groupedDictionary = Dictionary(grouping: value, by: keyForValue)
            .sorted {
                $0.key > $1.key
        }
        groupedDictionary.forEach {
            listItemsArray.append(
                ListItems(key: $0.key, value: $0.value)
            )
        }

        return listItemsArray
    }
}
