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
struct PreviewData { // swiftlint:disable function_body_length
    static let item = createItem(date: Date(),
                                 content: "Payday",
                                 income: 3500,
                                 outgo: 0,
                                 group: "Salary")

    static func screenShot(_ context: NSManagedObjectContext) -> [Item] {
        var items: [Item] = []

        let now = Date()
        let dateA = Calendar.current.date(byAdding: .day, value: 0, to: now)!
        let dateB = Calendar.current.date(byAdding: .day, value: 6, to: now)!
        let dateC = Calendar.current.date(byAdding: .day, value: 12, to: now)!
        let dateD = Calendar.current.date(byAdding: .day, value: 18, to: now)!
        let dateE = Calendar.current.date(byAdding: .day, value: 24, to: now)!

        for index in 0..<24 {
            items.append(createItem(date: monthLater(from: dateD, value: index),
                                    content: "Payday",
                                    income: 3500,
                                    outgo: 0,
                                    group: "Salary"))
            items.append(createItem(date: monthLater(from: dateD, value: index),
                                    content: "Advertising revenue",
                                    income: 485,
                                    outgo: 0,
                                    group: "Salary"))
            items.append(createItem(date: monthLater(from: dateB, value: index),
                                    content: "Apple card",
                                    income: 0,
                                    outgo: 1000,
                                    group: "Credit"))
            items.append(createItem(date: monthLater(from: dateA, value: index),
                                    content: "Orange card",
                                    income: 0,
                                    outgo: 800,
                                    group: "Credit"))
            items.append(createItem(date: monthLater(from: dateD, value: index),
                                    content: "Lemon card",
                                    income: 0,
                                    outgo: 500,
                                    group: "Credit"))
            items.append(createItem(date: monthLater(from: dateE, value: index),
                                    content: "House",
                                    income: 0,
                                    outgo: 30,
                                    group: "Loan"))
            items.append(createItem(date: monthLater(from: dateC, value: index),
                                    content: "Car",
                                    income: 0,
                                    outgo: 25,
                                    group: "Loan"))
            items.append(createItem(date: monthLater(from: dateA, value: index),
                                    content: "Insurance",
                                    income: 0,
                                    outgo: 28,
                                    group: "Tax"))
            items.append(createItem(date: monthLater(from: dateE, value: index),
                                    content: "Pension",
                                    income: 0,
                                    outgo: 36,
                                    group: "Tax"))
        }

        return items
    }

    private static func createItem(date: Date, content: String, income: NSDecimalNumber, outgo: NSDecimalNumber, group: String) -> Item {
        let item = Item()
        item.set(date: date, content: content, income: income, outgo: outgo, group: group, repeatID: UUID())
        return item
    }

    private static func monthLater(from date: Date = Date(), value: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: value, to: date)!
    }
}
#endif
