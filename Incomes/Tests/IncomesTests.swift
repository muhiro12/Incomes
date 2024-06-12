//
//  IncomesTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2022/01/14.
//  Copyright © 2022 Hiromu Nakano. All rights reserved.
//

@testable import IncomesPlaygrounds
import SwiftData
import XCTest

final class IncomesTests: XCTestCase {}

var context: ModelContext {
    try! .init(
        .init(
            for: Item.self,
            configurations: .init(
                isStoredInMemoryOnly: true
            )
        )
    )
}

let date: (String) -> Date = { string in
    try! Date(string, strategy: .iso8601)
}
// swiftlint:enable all
