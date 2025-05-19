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

let shiftedDate: (String) -> Date = { string in
    Calendar.current.shiftedDate(
        componentsFrom: isoDate(string),
        in: .utc
    )
}

let timeZones: [TimeZone] = [
    .init(identifier: "Asia/Tokyo")!,
    .init(identifier: "Europe/London")!,
    .init(identifier: "America/New_York")!,
    .init(identifier: "America/Santo_Domingo")!,
    .init(identifier: "Europe/Minsk")!
]

func fetchItems(_ context: ModelContext) -> [Item] {
    try! context.fetch(.items(.all))
}
