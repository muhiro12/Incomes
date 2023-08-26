//
//  IncomesTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2022/01/14.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

import CoreData
@testable import Incomes
import XCTest

// swiftlint:disable all
class IncomesTests: XCTestCase {}

var context: NSManagedObjectContext {
    PersistenceController(inMemory: true).container.viewContext
}

let date: (String) -> Date = { string in
    try! Date(string, strategy: .iso8601)
}
