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

    func save(_ item: Item,
              date: Date,
              content: String,
              income: Decimal,
              expenditure: Decimal,
              label: String,
              completion: (() -> Void)? = nil) {

        item.date = date
        item.content = content
        item.income = income.asNSDecimalNumber
        item.expenditure = expenditure.asNSDecimalNumber
        item.label = label
        item.group = nil

        do {
            try context.save()
            completion?()
        } catch {
            print(error)
        }
    }

    func create(date: Date,
                content: String,
                income: Decimal,
                expenditure: Decimal,
                label: String,
                repeatCount: Int,
                completion: (() -> Void)? = nil) {

        let group = UUID()

        for index in 0..<repeatCount {
            let item = Item(context: context)
            item.date = Calendar.current.date(byAdding: .month, value: index, to: date)
            item.content = content
            item.income = income.asNSDecimalNumber
            item.expenditure = expenditure.asNSDecimalNumber
            item.label = label
            item.group = group
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
