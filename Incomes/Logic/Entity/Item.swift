//
//  Item.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2021/12/29.
//  Copyright © 2021 Hiromu Nakano. All rights reserved.
//

import Foundation
import CoreData

@objc(Item)
public class Item: NSManagedObject {}

extension Item: Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: .item)
    }

    @NSManaged public var balance: NSDecimalNumber
    @NSManaged public var content: String
    @NSManaged public var date: Date
    @NSManaged public var group: String
    @NSManaged public var income: NSDecimalNumber
    @NSManaged public var outgo: NSDecimalNumber
    @NSManaged public var repeatID: UUID
    @NSManaged public var year: String
}

extension Item {
    func set(date: Date, content: String, income: NSDecimalNumber, outgo: NSDecimalNumber, group: String, repeatID: UUID = UUID()) -> Self {
        self.date = date
        self.year = date.yearString()
        self.content = content
        self.income = income
        self.outgo = outgo
        self.group = group
        self.repeatID = repeatID
        return self
    }

    var profit: NSDecimalNumber {
        income.subtracting(outgo)
    }

    var isProfitable: Bool {
        profit.isPlus
    }
}
