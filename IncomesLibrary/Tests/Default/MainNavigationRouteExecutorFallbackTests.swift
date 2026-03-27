import Foundation
@testable import IncomesLibrary
import Testing

struct MainNavigationRouteExecutorFallbackTests {
    let context = testContext

    @Test
    func execute_item_route_falls_back_to_home_for_invalid_identifier() throws {
        let expectedState = try MainNavigationStateLoader.load(context: context)
        let outcome = try MainNavigationRouteExecutor.execute(
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
            date: isoDate("2026-03-15T00:00:00Z"),
            content: "Salary",
            income: 2_000,
            outgo: .zero,
            category: "Income",
            priority: 0
        )
        let itemID = try item.id.base64Encoded()
        context.delete(item)
        let expectedState = try MainNavigationStateLoader.load(context: context)

        let outcome = try MainNavigationRouteExecutor.execute(
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
