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

final class IncomesTests: XCTestCase {}

var testContext: ModelContext {
    try! .init(
        .init(
            for: Item.self,
            configurations: .init(
                isStoredInMemoryOnly: true
            )
        )
    )
}

let isoDate: (String) -> Date = { string in
    guard let date = ISO8601DateFormatter().date(from: string) else {
        preconditionFailure("Invalid ISO8601 date string: \(string)")
    }
    return date
}

func fetchItems(_ context: ModelContext) -> [Item] {
    try! context.fetch(.items(.all))
}
