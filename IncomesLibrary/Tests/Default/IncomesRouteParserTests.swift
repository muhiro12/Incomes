import Foundation
@testable import IncomesLibrary
import Testing

struct IncomesRouteParserTests {
    @Test
    func parse_custom_scheme_year_route() {
        let route = IncomesRouteParser.parse(
            url: .init(string: "incomes://v1/year/2026")!
        )
        #expect(route == .year(2_026))
    }

    @Test
    func parse_custom_scheme_month_route_compact() {
        let route = IncomesRouteParser.parse(
            url: .init(string: "incomes://v1/month/202602")!
        )
        #expect(route == .month(year: 2_026, month: 2))
    }

    @Test
    func parse_custom_scheme_month_route_hyphenated() {
        let route = IncomesRouteParser.parse(
            url: .init(string: "incomes://v1/month/2026-12")!
        )
        #expect(route == .month(year: 2_026, month: 12))
    }

    @Test
    func parse_custom_scheme_settings_route() {
        let route = IncomesRouteParser.parse(
            url: .init(string: "incomes://v1/settings")!
        )
        #expect(route == .settings)
    }

    @Test
    func parse_custom_scheme_settings_subscription_route() {
        let route = IncomesRouteParser.parse(
            url: .init(string: "incomes://v1/settings/subscription")!
        )
        #expect(route == .settingsSubscription)
    }

    @Test
    func parse_custom_scheme_settings_license_route() {
        let route = IncomesRouteParser.parse(
            url: .init(string: "incomes://v1/settings/license")!
        )
        #expect(route == .settingsLicense)
    }

    @Test
    func parse_custom_scheme_settings_debug_route() {
        let route = IncomesRouteParser.parse(
            url: .init(string: "incomes://v1/settings/debug")!
        )
        #expect(route == .settingsDebug)
    }

    @Test
    func parse_custom_scheme_year_summary_route() {
        let route = IncomesRouteParser.parse(
            url: .init(string: "incomes://v1/year-summary/2026")!
        )
        #expect(route == .yearSummary(2_026))
    }

    @Test
    func parse_custom_scheme_yearly_duplication_route() {
        let route = IncomesRouteParser.parse(
            url: .init(string: "incomes://v1/yearly-duplication")!
        )
        #expect(route == .yearlyDuplication)
    }

    @Test
    func parse_custom_scheme_introduction_route() {
        let route = IncomesRouteParser.parse(
            url: .init(string: "incomes://v1/introduction")!
        )
        #expect(route == .introduction)
    }

    @Test
    func parse_custom_scheme_duplicate_tags_route() {
        let route = IncomesRouteParser.parse(
            url: .init(string: "incomes://v1/duplicate-tags")!
        )
        #expect(route == .duplicateTags)
    }

    @Test
    func parse_universal_link_route_with_prefix() {
        let route = IncomesRouteParser.parse(
            url: .init(string: "https://muhiro12.github.io/Incomes/v1/month/2026-01")!
        )
        #expect(route == .month(year: 2_026, month: 1))
    }

    @Test
    func parse_universal_link_route_without_prefix() {
        let route = IncomesRouteParser.parse(
            url: .init(string: "https://muhiro12.github.io/v1/year/2025")!
        )
        #expect(route == .year(2_025))
    }

    @Test
    func parse_rejects_unknown_universal_link_host() {
        let route = IncomesRouteParser.parse(
            url: .init(string: "https://example.com/Incomes/v1/settings")!
        )
        #expect(route == nil)
    }

    @Test
    func parse_search_route_with_query() {
        let route = IncomesRouteParser.parse(
            url: .init(string: "incomes://v1/search?q=rent")!
        )
        #expect(route == .search(query: "rent"))
    }

    @Test
    func parse_search_route_without_query() {
        let route = IncomesRouteParser.parse(
            url: .init(string: "incomes://v1/search")!
        )
        #expect(route == .search(query: nil))
    }

    @Test
    func parse_defaults_to_home_when_no_destination() {
        let customSchemeRoute = IncomesRouteParser.parse(
            url: .init(string: "incomes://v1")!
        )
        let universalLinkRoute = IncomesRouteParser.parse(
            url: .init(string: "https://muhiro12.github.io/Incomes/v1")!
        )
        #expect(customSchemeRoute == .home)
        #expect(universalLinkRoute == .home)
    }

    @Test
    func parse_returns_nil_for_invalid_month() {
        let route = IncomesRouteParser.parse(
            url: .init(string: "incomes://v1/month/2026-13")!
        )
        #expect(route == nil)
    }
}
