//
//  ListItems.swift
//  Incomes
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

        items.enumerated().forEach {
            let index = $0.offset
            let item = $0.element

            guard let date = item.date,
                let content = item.content,
                let income = item.income?.decimalValue,
                let expenditure = item.expenditure?.decimalValue else {
                    return
            }

            var balance = Decimal.zero
            if index > 0 {
                balance += listItems[index - 1].balance
            }
            balance += income - expenditure

            let listItem = ListItem(date: date,
                                    content: content,
                                    income: income,
                                    expenditure: expenditure,
                                    group: item.group.string,
                                    repeatId: item.repeatId,
                                    balance: balance,
                                    original: item)
            listItems.append(listItem)
        }

        self.init(key: .all, value: listItems.reversed())
    }

    func grouped(by keyForValue: (ListItem) -> String) -> [Self] {
        var listItemsArray: [ListItems] = []

        let groupedDictionary = Dictionary(grouping: value, by: keyForValue)
            .sorted {
                if $0.key.isEmpty {
                    return true
                } else if $1.key.isEmpty {
                    return false
                } else {
                    return $0.key > $1.key
                }
        }
        groupedDictionary.forEach {
            listItemsArray.append(
                ListItems(key: $0.key, value: $0.value)
            )
        }

        return listItemsArray
    }
}
