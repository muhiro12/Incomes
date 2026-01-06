//
//  TagTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2025/10/11.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct TagTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func hasDeficit_returns_true_when_any_item_has_negative_balance() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-01-01T00:00:00Z"),
            content: "First",
            income: .zero,
            outgo: 100,
            category: "Category",
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-01-02T00:00:00Z"),
            content: "Second",
            income: 200,
            outgo: .zero,
            category: "Category",
            repeatCount: 1
        )

        try ItemService.recalculate(
            context: context,
            date: .distantPast
        )

        let tag = try #require(
            try TagService.getByName(
                context: context,
                name: "2024",
                type: .year
            )
        )
        #expect(tag.hasDeficit == true)
    }

    @Test
    func hasDeficit_returns_false_when_all_items_have_non_negative_balance() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2024-02-01T00:00:00Z"),
            content: "Positive",
            income: 200,
            outgo: 100,
            category: "Category",
            repeatCount: 1
        )

        try ItemService.recalculate(
            context: context,
            date: .distantPast
        )

        let tag = try #require(
            try TagService.getByName(
                context: context,
                name: "2024",
                type: .year
            )
        )
        #expect(tag.hasDeficit == false)
    }
}
