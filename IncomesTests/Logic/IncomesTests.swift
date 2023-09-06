//
//  IncomesTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2022/01/14.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

@testable import Incomes
import SwiftData
import XCTest

// swiftlint:disable all
class IncomesTests: XCTestCase {}

var context: ModelContext {
    ModelContext(PreviewData.inMemoryContainer)
}

let date: (String) -> Date = { string in
    try! Date(string, strategy: .iso8601)
}
// swiftlint:enable all
