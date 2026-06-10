import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct MainNavigationContextMenuLinkTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func preferred_url_returns_nil_for_missing_route() {
        let url = MainNavigationOperations.preferredURL(for: nil)

        #expect(url == nil)
    }

    @Test
    func preferred_url_returns_settings_route_url() {
        let url = MainNavigationOperations.preferredURL(for: .settings)

        #expect(
            url?.absoluteString == "https://muhiro12.github.io/Incomes/settings"
        )
    }

    @Test
    func preferred_url_returns_route_url() {
        let url = MainNavigationOperations.preferredURL(for: .year(2_026))

        #expect(
            url?.absoluteString == "https://muhiro12.github.io/Incomes/year/2026"
        )
    }

    @Test
    func preferred_url_returns_month_url_for_date() {
        let url = MainNavigationOperations.preferredURL(
            forMonthContaining: shiftedDate("2026-04-10T12:00:00Z")
        )

        #expect(
            url?.absoluteString == "https://muhiro12.github.io/Incomes/month/2026-04"
        )
    }

    @Test
    func preferred_url_returns_item_url() throws {
        let item = try createItem(
            context: context,
            date: shiftedDate("2000-01-01T12:00:00Z"),
            content: "A",
            income: 100,
            outgo: 0,
            category: "Test",
            priority: 0,
            repeatCount: 1
        )
        let itemID = try PersistentIdentifierCoder.encode(item.id)

        let url = MainNavigationOperations.preferredURL(for: item)

        #expect(
            url?.absoluteString == "https://muhiro12.github.io/Incomes/item?id=\(itemID)"
        )
    }

    @Test
    func year_route_returns_year_route_for_year_tag() throws {
        let tag = try Tag.create(context: context, name: "2026", type: .year)

        let route = MainNavigationOperations.route(forYearTag: tag)

        #expect(route == .year(2_026))
    }

    @Test
    func year_summary_route_returns_year_summary_route_for_year_tag() throws {
        let tag = try Tag.create(context: context, name: "2026", type: .year)

        let route = MainNavigationOperations.yearSummaryRoute(forYearTag: tag)

        #expect(route == .yearSummary(2_026))
    }

    @Test
    func year_route_returns_nil_for_non_year_tag() throws {
        let tag = try Tag.create(context: context, name: "202601", type: .yearMonth)

        let route = MainNavigationOperations.route(forYearTag: tag)

        #expect(route == nil)
    }

    @Test
    func month_route_returns_month_route_for_year_month_tag() throws {
        let tag = try Tag.create(context: context, name: "202601", type: .yearMonth)

        let route = MainNavigationOperations.route(forYearMonthTag: tag)

        #expect(route == .month(year: 2_026, month: 1))
    }

    @Test
    func month_route_returns_nil_for_non_year_month_tag() throws {
        let tag = try Tag.create(context: context, name: "2026", type: .year)

        let route = MainNavigationOperations.route(forYearMonthTag: tag)

        #expect(route == nil)
    }
}
