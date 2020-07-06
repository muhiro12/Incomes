//
//  PreviewData.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/26.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation

#if DEBUG
struct PreviewData {
    struct Item {
        let date: Date?
        let content: String?
        let income: NSDecimalNumber?
        let expenditure: NSDecimalNumber?
        let balance: NSDecimalNumber?
        let group: String?
        let repeatId: UUID? = nil
    }

    static let listItem = ListItem(date: Date(),
                                   content: LocalizableStrings.content.localized,
                                   group: .empty,
                                   income: 999999,
                                   expenditure: 99999,
                                   balance: 9999999)

    static let listItems = ListItems(key: LocalizableStrings.all.localized,
                                     value: [listItem, listItem])

    static let sectionItems = SectionItems(key: Date().year,
                                           value: [listItems])

    static var screenShot: ListItems {
        var items: [Item] = []

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date5 = formatter.date(from: "2020-06-05")!
        let date10 = formatter.date(from: "2020-06-10")!
        let date25 = formatter.date(from: "2020-06-25")!
        let date27 = formatter.date(from: "2020-06-27")!
        let date28 = formatter.date(from: "2020-06-28")!

        for index in 0..<24 {
            items.append(Item(date: monthLater(from: date27, value: index),
                              content: "Payday",
                              income: 3500,
                              expenditure: 0,
                              balance: 0,
                              group: "Salary"))
            items.append(Item(date: monthLater(from: date27, value: index),
                              content: "Advertising revenue",
                              income: 485,
                              expenditure: 0,
                              balance: 0,
                              group: "Salary"))
            items.append(Item(date: monthLater(from: date10, value: index),
                              content: "Apple card",
                              income: 0,
                              expenditure: 1000,
                              balance: 0,
                              group: "Credit"))
            items.append(Item(date: monthLater(from: date5, value: index),
                              content: "Orange card",
                              income: 0,
                              expenditure: 800,
                              balance: 0,
                              group: "Credit"))
            items.append(Item(date: monthLater(from: date27, value: index),
                              content: "Lemon card",
                              income: 0,
                              expenditure: 500,
                              balance: 0,
                              group: "Credit"))
            items.append(Item(date: monthLater(from: date28, value: index),
                              content: "House",
                              income: 0,
                              expenditure: 30,
                              balance: 0,
                              group: "Loan"))
            items.append(Item(date: monthLater(from: date25, value: index),
                              content: "Car",
                              income: 0,
                              expenditure: 25,
                              balance: 0,
                              group: "Loan"))
            items.append(Item(date: monthLater(from: date5, value: index),
                              content: "Insurance",
                              income: 0,
                              expenditure: 28,
                              balance: 0,
                              group: "Tax"))
            items.append(Item(date: monthLater(from: date28, value: index),
                              content: "Pension",
                              income: 0,
                              expenditure: 36,
                              balance: 0,
                              group: "Tax"))
        }

        items.sort(by: { $0.date! < $1.date! })

        return create(from: items)
    }

    private static func create(from items: [Item]) -> ListItems {
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
                                    group: item.group.string,
                                    income: income,
                                    expenditure: expenditure,
                                    balance: balance,
                                    original: nil)
            listItems.append(listItem)
        }

        return ListItems(key: LocalizableStrings.all.localized, value: listItems.reversed())
    }

    private static func monthLater(from date: Date = Date(), value: Int) -> Date {
        return Calendar.current.date(byAdding: .month,
                                     value: value,
                                     to: date)!
    }
}
#endif
