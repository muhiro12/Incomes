//
//  ItemRepositoryTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2022/01/14.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import XCTest
@testable import Incomes
import CoreData

class ItemRepositoryTests: XCTestCase {
    var context: NSManagedObjectContext {
        PersistenceController(inMemory: true).container.viewContext
    }

    let date: (String) -> Date = { string in
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        formatter.locale = .init(identifier: "en_US_POSIX")
        formatter.timeZone = .init(secondsFromGMT: 0)
        return formatter.date(from: string)!
    }
}
