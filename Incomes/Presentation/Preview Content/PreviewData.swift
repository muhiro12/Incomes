//
//  PreviewData.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/26.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation
import CoreData

#if DEBUG
struct PreviewData {
    static let listItem = Item().set(date: Date(),
                                     content: "Payday",
                                     income: 3500,
                                     outgo: 0,
                                     group: "Salary")

    // swiftlint:disable function_body_length
    static func screenShot(_ context: NSManagedObjectContext) -> [Item] {
        var items: [Item] = []

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date5 = formatter.date(from: "2021-06-05")!
        let date10 = formatter.date(from: "2021-06-10")!
        let date25 = formatter.date(from: "2021-06-25")!
        let date27 = formatter.date(from: "2021-06-27")!
        let date28 = formatter.date(from: "2021-06-28")!

        for index in 0..<24 {
            items.append(Item(context: context).set(date: monthLater(from: date27, value: index),
                                                    content: "Payday",
                                                    income: 3500,
                                                    outgo: 0,
                                                    group: "Salary"))
            items.append(Item(context: context).set(date: monthLater(from: date27, value: index),
                                                    content: "Advertising revenue",
                                                    income: 485,
                                                    outgo: 0,
                                                    group: "Salary"))
            items.append(Item(context: context).set(date: monthLater(from: date10, value: index),
                                                    content: "Apple card",
                                                    income: 0,
                                                    outgo: 1000,
                                                    group: "Credit"))
            items.append(Item(context: context).set(date: monthLater(from: date5, value: index),
                                                    content: "Orange card",
                                                    income: 0,
                                                    outgo: 800,
                                                    group: "Credit"))
            items.append(Item(context: context).set(date: monthLater(from: date27, value: index),
                                                    content: "Lemon card",
                                                    income: 0,
                                                    outgo: 500,
                                                    group: "Credit"))
            items.append(Item(context: context).set(date: monthLater(from: date28, value: index),
                                                    content: "House",
                                                    income: 0,
                                                    outgo: 30,
                                                    group: "Loan"))
            items.append(Item(context: context).set(date: monthLater(from: date25, value: index),
                                                    content: "Car",
                                                    income: 0,
                                                    outgo: 25,
                                                    group: "Loan"))
            items.append(Item(context: context).set(date: monthLater(from: date5, value: index),
                                                    content: "Insurance",
                                                    income: 0,
                                                    outgo: 28,
                                                    group: "Tax"))
            items.append(Item(context: context).set(date: monthLater(from: date28, value: index),
                                                    content: "Pension",
                                                    income: 0,
                                                    outgo: 36,
                                                    group: "Tax"))
        }

        items.sort(by: { $0.date < $1.date })

        return items
    }

    private static func monthLater(from date: Date = Date(), value: Int) -> Date {
        return Calendar.current.date(byAdding: .month,
                                     value: value,
                                     to: date)!
    }
}
#endif
