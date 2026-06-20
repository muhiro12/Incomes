//
//  ItemTest.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/04/25.
//

import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

@Suite(.serialized)
struct ItemTest {
    let context = testContext

    init() {
        TimeZone.ReferenceType.default = .current
    }
}
