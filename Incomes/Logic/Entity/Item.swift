//
//  Item.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import CoreData
import Foundation

@objc(Item)
public class Item: NSManagedObject {}

extension Item: Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        NSFetchRequest<Item>(entityName: .item)
    }

    @NSManaged public var balance: NSDecimalNumber
    @NSManaged public var content: String
    @NSManaged public var date: Date
    @NSManaged public var group: String
    @NSManaged public var income: NSDecimalNumber
    @NSManaged public var outgo: NSDecimalNumber
    @NSManaged public var repeatID: UUID
    @NSManaged public var startOfYear: Date
}

extension Item {
    func set(date: Date, // swiftlint:disable:this function_parameter_count
             content: String,
             income: NSDecimalNumber,
             outgo: NSDecimalNumber,
             group: String,
             repeatID: UUID) {
        self.content = content
        self.income = income
        self.outgo = outgo
        self.group = group
        self.repeatID = repeatID

        self.date = Calendar.utc.startOfDay(for: date)
        self.startOfYear = Calendar.utc.startOfYear(for: date)
    }

    var profit: NSDecimalNumber {
        income.subtracting(outgo)
    }

    var isProfitable: Bool {
        profit.isPlus
    }
}
