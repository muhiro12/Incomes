//
//  PreviewData.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/06/26.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation
import CoreData

struct PreviewData {
    let context: NSManagedObjectContext
    let repository: any Repository<Item>

    init(context: NSManagedObjectContext = PersistenceController.preview.container.viewContext) {
        self.context = context
        self.repository = ItemRepository(context: context)
    }

    var item: Item {
        item(date: Date(),
             content: "Payday",
             income: 3500,
             outgo: 0,
             group: "Salary")
    }

    var items: [Item] {
        var items: [Item] = []

        let now = Calendar.utc.startOfYear(for: Date())
        let dateA = Calendar.utc.date(byAdding: .day, value: 0, to: now)!
        let dateB = Calendar.utc.date(byAdding: .day, value: 6, to: now)!
        let dateC = Calendar.utc.date(byAdding: .day, value: 12, to: now)!
        let dateD = Calendar.utc.date(byAdding: .day, value: 18, to: now)!
        let dateE = Calendar.utc.date(byAdding: .day, value: 24, to: now)!

        for index in 0..<24 {
            items.append(item(date: date(monthLater: index, from: dateD),
                              content: "Payday",
                              income: 3500,
                              outgo: 0,
                              group: "Salary"))
            items.append(item(date: date(monthLater: index, from: dateD),
                              content: "Advertising revenue",
                              income: 485,
                              outgo: 0,
                              group: "Salary"))
            items.append(item(date: date(monthLater: index, from: dateB),
                              content: "Apple card",
                              income: 0,
                              outgo: 1000,
                              group: "Credit"))
            items.append(item(date: date(monthLater: index, from: dateA),
                              content: "Orange card",
                              income: 0,
                              outgo: 800,
                              group: "Credit"))
            items.append(item(date: date(monthLater: index, from: dateD),
                              content: "Lemon card",
                              income: 0,
                              outgo: 500,
                              group: "Credit"))
            items.append(item(date: date(monthLater: index, from: dateE),
                              content: "House",
                              income: 0,
                              outgo: 30,
                              group: "Loan"))
            items.append(item(date: date(monthLater: index, from: dateC),
                              content: "Car",
                              income: 0,
                              outgo: 25,
                              group: "Loan"))
            items.append(item(date: date(monthLater: index, from: dateA),
                              content: "Insurance",
                              income: 0,
                              outgo: 28,
                              group: "Tax"))
            items.append(item(date: date(monthLater: index, from: dateE),
                              content: "Pension",
                              income: 0,
                              outgo: 36,
                              group: "Tax"))
        }

        return items
    }

    func item(date: Date, content: String, income: NSDecimalNumber, outgo: NSDecimalNumber, group: String) -> Item {
        let item = Item(context: context)
        item.set(date: date,
                 content: content,
                 income: income,
                 outgo: outgo,
                 group: group,
                 repeatID: UUID())
        do {
            try repository.add(item)
        } catch {
            assertionFailure()
        }
        return item
    }

    func date(monthLater: Int, from date: Date = Date()) -> Date {
        return Calendar.utc.date(byAdding: .month, value: monthLater, to: date)!
    }
}
