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

    init(from items: [Item], for key: String = .localized(.all)) {
        var listItems: [ListItem] = []

        items.enumerated().forEach {
            let index = $0.offset
            let item = $0.element

            guard let date = item.date,
                  let content = item.content,
                  let income = item.income?.decimalValue,
                  let expenditure = item.expenditure?.decimalValue
            else {
                assertionFailure()
                return
            }

            var balance = Decimal.zero
            if index > 0 {
                balance += listItems[index - 1].balance
            }
            balance += income - expenditure

            let listItem = ListItem(date: date,
                                    content: content,
                                    group: item.group.string,
                                    income: income,
                                    expenditure: expenditure,
                                    balance: balance,
                                    original: item)
            listItems.append(listItem)
        }

        self.init(key: key, value: listItems.reversed())
    }

    func grouped(by keyForValue: (ListItem) -> String, sortOption: SortOption = .string) -> [Self] {
        var listItemsArray: [ListItems] = []

        let groupedDictionary = Dictionary(grouping: value, by: keyForValue)
        groupedDictionary.sorted(by: sortOption.value).forEach {
            listItemsArray.append(
                ListItems(key: $0.key, value: $0.value)
            )
        }

        return listItemsArray
    }

    enum SortOption {
        case string
        case date

        func value(left: (key: String, value: [ListItem]),
                   right: (key: String, value: [ListItem])) -> Bool {
            switch self {
            case .string:
                if left.key.isEmpty {
                    return true
                } else if right.key.isEmpty {
                    return false
                } else {
                    return left.key > right.key
                }
            case .date:
                let leftDate = (left.value.first?.date).string
                let rightDate = (right.value.first?.date).string
                return leftDate > rightDate
            }
        }
    }
}
