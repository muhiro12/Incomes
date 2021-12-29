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

}

extension Item: Identifiable {

}

extension Item {
    convenience init(context: NSManagedObjectContext, date: Date, content: String, income: Decimal, outgo: Decimal, group: String, repeatID: UUID = UUID()) {
        self.init(context: context)
        self.date = date
        self.content = content
        self.income = income.nsValue
        self.outgo = outgo.nsValue
        self.group = group
        self.repeatId = repeatID
    }

    var profit: Decimal {
        income.decimalValue - outgo.decimalValue
    }

    var isProfitable: Bool {
        profit > 0
    }
}
