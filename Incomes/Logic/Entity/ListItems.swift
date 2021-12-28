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
    let value: [Item]

    init(key: String, value: [Item]) {
        self.key = key
        self.value = value
    }

    init(from items: [Item], for key: String = .localized(.all)) {
        var listItems: [Item] = []

        items.enumerated().forEach {
            let item = $0.element

            guard let date = item.date,
                  let content = item.content,
                  let income = item.income?.decimalValue,
                  let expenditure = item.outgo?.decimalValue
            else {
                assertionFailure()
                return
            }

            let listItem = Item(date: date,
                                content: content,
                                income: income,
                                outgo: expenditure,
                                group: item.group.unwrapped,
                                repeatID: UUID())

            listItems.append(listItem)
        }

        self.init(key: key, value: listItems.reversed())
    }

    func grouped(by keyForValue: (Item) -> String, sortOption: SortOption = .string) -> [Self] {
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

        func value(left: (key: String, value: [Item]),
                   right: (key: String, value: [Item])) -> Bool {
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
                let leftDate = (left.value.first?.date).unwrapped
                let rightDate = (right.value.first?.date).unwrapped
                return leftDate > rightDate
            }
        }
    }
}
