//
//  TagPredicateTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2025/10/11.
//

import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct TagPredicateTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func nameContains_matches_hiragana_and_katakana_variants() throws {
        _ = try Tag.create(context: context, name: "カタカナ", type: .content)

        let results = try context.fetch(
            .tags(.nameContains("かたかな", type: .content))
        )

        #expect(results.count == 1)
        #expect(results.first?.name == "カタカナ")
    }

    @Test
    func nameStartsWith_matches_prefix() throws {
        _ = try Tag.create(context: context, name: "AlphaBeta", type: .content)

        let results = try context.fetch(
            .tags(.nameStartsWith("Alpha", type: .content))
        )

        #expect(results.count == 1)
        #expect(results.first?.name == "AlphaBeta")
    }
}
