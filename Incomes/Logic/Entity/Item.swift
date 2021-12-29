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
public class Item: NSManagedObject {

}

extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var content: String
    @NSManaged public var date: Date
    @NSManaged public var group: String
    @NSManaged public var income: NSDecimalNumber
    @NSManaged public var outgo: NSDecimalNumber
    @NSManaged public var repeatId: UUID
    @NSManaged public var year: String

}

extension Item: Identifiable {

}

extension Item {
    func set(date: Date, content: String, income: NSDecimalNumber, outgo: NSDecimalNumber, group: String, repeatID: UUID = UUID()) -> Self {
        self.date = date
        self.year = date.yearString()
        self.content = content
        self.income = income
        self.outgo = outgo
        self.group = group
        self.repeatId = repeatID
        return self
    }

    var profit: NSDecimalNumber {
        income.subtracting(outgo)
    }

    var isProfitable: Bool {
        profit.isPlus
    }
}
