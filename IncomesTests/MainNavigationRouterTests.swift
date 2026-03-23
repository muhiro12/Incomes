import Foundation
@testable import Incomes
import IncomesLibrary
import SwiftData
import SwiftUI
import Testing

@MainActor
struct MainNavigationRouterTests {
    @Test
    func select_year_tag_id_clears_search_state_and_updates_column() {
        let router = MainNavigationRouter()
        router.isSearchPresented = true
        router.searchText = "rent"
        router.predicate = .all

        router.selectYearTagID(nil)

        #expect(router.isSearchPresented == false)
        #expect(router.searchText.isEmpty)
        #expect(router.predicate == nil)
        #expect(router.preferredCompactColumn == .sidebar)
    }

    @Test
    func select_search_predicate_moves_detail_column_when_search_is_active() {
        let router = MainNavigationRouter()
        router.isSearchPresented = true

        router.selectSearchPredicate(.all)
        #expect(router.preferredCompactColumn == .detail)

        router.selectSearchPredicate(nil)
        #expect(router.preferredCompactColumn == .content)
    }

    @Test
    func navigate_to_settings_subscription_sets_sheet_and_destination() throws {
        let router = MainNavigationRouter()
        let modelContainer = try IncomesPlatformEnvironmentFactory.makePreviewModelContainer()

        try router.navigate(
            to: .settingsSubscription,
            context: modelContainer.mainContext
        )

        #expect(router.sheetRoute == .settings)
        #expect(router.settingsDestination == .subscription)
    }
}
