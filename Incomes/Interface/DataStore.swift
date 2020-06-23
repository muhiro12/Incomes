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

    func save(_ item: Item, date: Date, content: String, income: Int, expenditure: Int, completion: (() -> Void)? = nil) {
        item.date = date
        item.content = content
        item.income = Int32(income)
        item.expenditure = Int32(expenditure)

        do {
            try context.save()
            completion?()
        } catch {
            print(error)
        }
    }

    func create(date: Date, content: String, income: Int, expenditure: Int, times: Int, completion: (() -> Void)? = nil) {
        for index in 0..<times {
            let item = Item(context: context)
            item.date = Calendar.current.date(byAdding: .month, value: index, to: date)
            item.content = content
            item.income = Int32(income)
            item.expenditure = Int32(expenditure)
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
