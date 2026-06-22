import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct MainNavigationOperationsFallbackTests {
    let context = testContext

    @Test
    func execute_item_route_falls_back_to_home_for_invalid_identifier() throws {
        let expectedState = try MainNavigationOperations.loadState(context: context)
        let outcome = try MainNavigationOperations.execute(
            route: .item("invalid"),
            context: context
        )

        switch outcome {
        case let .destination(yearTagID, selectedTag):
            #expect(yearTagID == expectedState.yearTag?.persistentModelID)
            #expect(
                selectedTag?.persistentModelID == expectedState.yearMonthTag?.persistentModelID
            )
        case .search,
             .settings,
             .settingsSubscription,
             .settingsLicense,
             .settingsDebug,
             .yearlyDuplication,
             .duplicateTags,
             .orphanTags,
             .itemDetail:
            Issue.record("Expected a home fallback destination.")
        }
    }

    @Test
    func execute_item_route_falls_back_to_home_when_item_is_missing() throws {
        let item = try createItem(
            context: context,
            input: .init(
                date: isoDate("2026-03-15T00:00:00Z"),
                content: "Salary",
                income: 2_000,
                outgo: .zero,
                category: "Income",
                priority: 0
            )
        )
        let itemID = try PersistentIdentifierCoder.encode(item.id)
        context.delete(item)
        let expectedState = try MainNavigationOperations.loadState(context: context)

        let outcome = try MainNavigationOperations.execute(
            route: .item(itemID),
            context: context
        )

        switch outcome {
        case let .destination(yearTagID, selectedTag):
            #expect(yearTagID == expectedState.yearTag?.persistentModelID)
            #expect(
                selectedTag?.persistentModelID == expectedState.yearMonthTag?.persistentModelID
            )
        case .search,
             .settings,
             .settingsSubscription,
             .settingsLicense,
             .settingsDebug,
             .yearlyDuplication,
             .duplicateTags,
             .orphanTags,
             .itemDetail:
            Issue.record("Expected a home fallback destination.")
        }
    }
}
