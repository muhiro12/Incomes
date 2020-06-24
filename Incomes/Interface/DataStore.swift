//
//  DataStore.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2020/04/13.
//  Copyright © 2020 Hiromu Nakano. All rights reserved.
//

import Foundation
import CoreData

struct DataStore {
    let context: NSManagedObjectContext

    func save(_ item: Item, date: Date, content: String, income: Decimal, expenditure: Decimal, completion: (() -> Void)? = nil) {
        item.date = date
        item.content = content
        item.income = income.asNSDecimalNumber
        item.expenditure = expenditure.asNSDecimalNumber

        do {
            try context.save()
            completion?()
        } catch {
            print(error)
        }
    }

    func create(date: Date, content: String, income: Decimal, expenditure: Decimal, repeatCount: Int, completion: (() -> Void)? = nil) {
        for index in 0..<repeatCount {
            let item = Item(context: context)
            item.date = Calendar.current.date(byAdding: .month, value: index, to: date)
            item.content = content
            item.income = income.asNSDecimalNumber
            item.expenditure = expenditure.asNSDecimalNumber
        }

        do {
            try context.save()
            completion?()
        } catch {
            print(error)
        }
    }

    func delete(_ item: Item, completion: (() -> Void)? = nil) {
        context.delete(item)
        completion?()
    }
}
