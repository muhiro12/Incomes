import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct MainNavigationRestorationTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func restorable_route_prefers_the_selected_month() throws {
        let yearTag = try Tag.create(context: context, name: "2002", type: .year)
        let monthTag = try Tag.create(context: context, name: "200204", type: .yearMonth)

        let route = MainNavigationOperations.restorableRoute(
            yearTag: yearTag,
            selectedTag: monthTag
        )

        #expect(route == .month(year: 2_002, month: 4))
    }

    @Test
    func restorable_route_maps_a_selected_year_tag_to_its_summary() throws {
        let yearTag = try Tag.create(context: context, name: "2002", type: .year)

        let route = MainNavigationOperations.restorableRoute(
            yearTag: yearTag,
            selectedTag: yearTag
        )

        #expect(route == .yearSummary(2_002))
    }

    @Test
    func restorable_route_falls_back_to_the_year_for_other_selections() throws {
        let yearTag = try Tag.create(context: context, name: "2002", type: .year)
        let categoryTag = try Tag.create(context: context, name: "Food", type: .category)

        #expect(
            MainNavigationOperations.restorableRoute(yearTag: yearTag, selectedTag: nil) == .year(2_002)
        )
        #expect(
            MainNavigationOperations.restorableRoute(yearTag: yearTag, selectedTag: categoryTag) == .year(2_002)
        )
        #expect(
            MainNavigationOperations.restorableRoute(yearTag: nil, selectedTag: nil) == nil
        )
    }

    @Test(arguments: [
        IncomesRoute.year(2_002),
        .yearSummary(2_002),
        .month(year: 2_002, month: 4)
    ])
    func restoration_url_round_trips_restorable_routes(route: IncomesRoute) throws {
        let url = try #require(MainNavigationOperations.restorationURL(for: route))

        #expect(MainNavigationOperations.restorableRoute(from: url) == route)
    }

    @Test
    func restored_routes_resolve_missing_entities_without_a_stale_selection() throws {
        let yearTag = try Tag.create(context: context, name: "2002", type: .year)

        let missingMonth = try MainNavigationOperations.execute(
            route: .month(year: 2_002, month: 4),
            context: context
        )
        let missingYear = try MainNavigationOperations.execute(
            route: .month(year: 1_999, month: 4),
            context: context
        )

        guard case let .destination(monthYearTagID, monthSelection) = missingMonth,
              case let .destination(missingYearTagID, missingYearSelection) = missingYear else {
            Issue.record("Restorable routes must resolve to destinations")
            return
        }
        #expect(monthYearTagID == yearTag.persistentModelID)
        #expect(monthSelection == nil)
        #expect(missingYearTagID == nil)
        #expect(missingYearSelection == nil)
    }

    @Test(arguments: [
        IncomesRoute.home,
        .settings,
        .yearlyDuplication,
        .search(query: "Rent"),
        .item("encoded-item-id")
    ])
    func session_only_routes_are_never_restored(route: IncomesRoute) throws {
        #expect(MainNavigationOperations.restorationURL(for: route) == nil)

        let url = try #require(MainNavigationOperations.preferredURL(for: route))
        #expect(MainNavigationOperations.restorableRoute(from: url) == nil)
    }
}
