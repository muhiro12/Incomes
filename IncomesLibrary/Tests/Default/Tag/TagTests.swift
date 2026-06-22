//
//  TagTests.swift
//  IncomesLibraryTests
//
//  Created by Hiromu Nakano on 2025/10/11.
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
    func create_reuses_existing_tag_for_same_name_and_type() throws {
        let first = try Tag.create(
            context: context,
            name: "Shared",
            type: .content
        )
        let second = try Tag.create(
            context: context,
            name: "Shared",
            type: .content
        )

        #expect(first.id == second.id)
        #expect(
            try context.fetchCount(
                .tags(.nameIs("Shared", type: .content))
            ) == 1
        )
    }

    @Test
    func hasDeficit_returns_true_when_any_item_has_negative_balance() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-01-01T00:00:00Z"),
                content: "First",
                income: .zero,
                outgo: 100,
                category: "Category",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-01-02T00:00:00Z"),
                content: "Second",
                income: 200,
                outgo: .zero,
                category: "Category",
                priority: 0
            ),
            repeatCount: 1
        )

        try ItemBalanceOperations.recalculate(
            context: context,
            date: .distantPast
        )

        let tag = try #require(
            try TagQueryOperations.getByName(
                context: context,
                name: "2024",
                type: .year
            )
        )
        #expect(tag.hasDeficit == true)
    }

    @Test
    func hasDeficit_returns_false_when_all_items_have_non_negative_balance() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-02-01T00:00:00Z"),
                content: "Positive",
                income: 200,
                outgo: 100,
                category: "Category",
                priority: 0
            ),
            repeatCount: 1
        )

        try ItemBalanceOperations.recalculate(
            context: context,
            date: .distantPast
        )

        let tag = try #require(
            try TagQueryOperations.getByName(
                context: context,
                name: "2024",
                type: .year
            )
        )
        #expect(tag.hasDeficit == false)
    }
}
