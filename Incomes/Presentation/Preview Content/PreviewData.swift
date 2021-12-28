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

    static let listItem = Item(date: Date(),
                               content: .localized(.content),
                               income: 999999,
                               outgo: 99999,
                               group: .empty,
                               repeatID: UUID())

    static let listItems = ListItems(key: .localized(.all),
                                     value: [listItem, listItem])

    static let sectionItems = SectionItems(key: Date().stringValue(.yyyy),
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
                              outgo: 0,
                              group: "Salary",
                              repeatID: UUID()))
            items.append(Item(date: monthLater(from: date27, value: index),
                              content: "Advertising revenue",
                              income: 485,
                              outgo: 0,
                              group: "Salary",
                              repeatID: UUID()))
            items.append(Item(date: monthLater(from: date10, value: index),
                              content: "Apple card",
                              income: 0,
                              outgo: 1000,
                              group: "Credit",
                              repeatID: UUID()))
            items.append(Item(date: monthLater(from: date5, value: index),
                              content: "Orange card",
                              income: 0,
                              outgo: 800,
                              group: "Credit",
                              repeatID: UUID()))
            items.append(Item(date: monthLater(from: date27, value: index),
                              content: "Lemon card",
                              income: 0,
                              outgo: 500,
                              group: "Credit",
                              repeatID: UUID()))
            items.append(Item(date: monthLater(from: date28, value: index),
                              content: "House",
                              income: 0,
                              outgo: 30,
                              group: "Loan",
                              repeatID: UUID()))
            items.append(Item(date: monthLater(from: date25, value: index),
                              content: "Car",
                              income: 0,
                              outgo: 25,
                              group: "Loan",
                              repeatID: UUID()))
            items.append(Item(date: monthLater(from: date5, value: index),
                              content: "Insurance",
                              income: 0,
                              outgo: 28,
                              group: "Tax",
                              repeatID: UUID()))
            items.append(Item(date: monthLater(from: date28, value: index),
                              content: "Pension",
                              income: 0,
                              outgo: 36,
                              group: "Tax",
                              repeatID: UUID()))
        }

        items.sort(by: { $0.date! < $1.date! })

        return create(from: items)
    }

    private static func create(from items: [Item]) -> ListItems {
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

        return ListItems(key: .localized(.all), value: listItems.reversed())
    }

    private static func monthLater(from date: Date = Date(), value: Int) -> Date {
        return Calendar.current.date(byAdding: .month,
                                     value: value,
                                     to: date)!
    }
}
#endif
