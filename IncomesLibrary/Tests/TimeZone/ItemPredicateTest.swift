//
//  ItemPredicateTest.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/04/25.
//

import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

@Suite(.serialized)
struct ItemPredicateTest {
    let context: ModelContext

    init() {
        context = testContext
    }
}
