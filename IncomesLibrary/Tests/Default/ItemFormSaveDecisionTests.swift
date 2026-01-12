import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct ItemFormSaveDecisionTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func requiresScopeSelection_returns_false_for_single_item() throws {
        let item = try Item.create(
            context: context,
            date: shiftedDate("2001-01-01T00:00:00Z"),
            content: "Content",
            income: 0,
            outgo: 10,
            category: "Category",
            repeatID: .init()
        )

        let requiresSelection = try ItemFormSaveDecision.requiresScopeSelection(
            context: context,
            item: item
        )
        #expect(requiresSelection == false)
    }

    @Test
    func requiresScopeSelection_returns_true_for_repeat_group() throws {
        let repeatID = UUID()
        let item = try Item.create(
            context: context,
            date: shiftedDate("2001-01-01T00:00:00Z"),
            content: "Content",
            income: 0,
            outgo: 10,
            category: "Category",
            repeatID: repeatID
        )
        _ = try Item.create(
            context: context,
            date: shiftedDate("2001-02-01T00:00:00Z"),
            content: "Content",
            income: 0,
            outgo: 10,
            category: "Category",
            repeatID: repeatID
        )

        let requiresSelection = try ItemFormSaveDecision.requiresScopeSelection(
            context: context,
            item: item
        )
        #expect(requiresSelection == true)
    }
}
