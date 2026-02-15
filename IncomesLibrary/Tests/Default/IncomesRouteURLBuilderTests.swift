import Foundation
@testable import IncomesLibrary
import Testing

struct IncomesRouteURLBuilderTests {
    @Test
    func build_custom_scheme_url_for_month() {
        let route = IncomesRoute.month(year: 2_026, month: 4)
        let url = IncomesRouteURLBuilder.customSchemeURL(for: route)
        #expect(
            url?.absoluteString == "incomes://v1/month/2026-04"
        )
    }

    @Test
    func build_universal_link_url_for_search() {
        let route = IncomesRoute.search(query: "gas")
        let url = IncomesRouteURLBuilder.universalLinkURL(
            for: route,
            host: "muhiro12.github.io",
            appPathPrefix: "Incomes"
        )
        #expect(
            url?.absoluteString == "https://muhiro12.github.io/Incomes/v1/search?q=gas"
        )
    }

    @Test
    func build_custom_scheme_url_for_yearly_duplication() {
        let route = IncomesRoute.yearlyDuplication
        let url = IncomesRouteURLBuilder.customSchemeURL(for: route)
        #expect(
            url?.absoluteString == "incomes://v1/yearly-duplication"
        )
    }

    @Test
    func build_custom_scheme_url_for_introduction() {
        let route = IncomesRoute.introduction
        let url = IncomesRouteURLBuilder.customSchemeURL(for: route)
        #expect(
            url?.absoluteString == "incomes://v1/introduction"
        )
    }

    @Test
    func build_custom_scheme_url_for_duplicate_tags() {
        let route = IncomesRoute.duplicateTags
        let url = IncomesRouteURLBuilder.customSchemeURL(for: route)
        #expect(
            url?.absoluteString == "incomes://v1/duplicate-tags"
        )
    }

    @Test
    func build_custom_scheme_url_for_settings_subscription() {
        let route = IncomesRoute.settingsSubscription
        let url = IncomesRouteURLBuilder.customSchemeURL(for: route)
        #expect(
            url?.absoluteString == "incomes://v1/settings/subscription"
        )
    }

    @Test
    func build_custom_scheme_url_for_settings_license() {
        let route = IncomesRoute.settingsLicense
        let url = IncomesRouteURLBuilder.customSchemeURL(for: route)
        #expect(
            url?.absoluteString == "incomes://v1/settings/license"
        )
    }

    @Test
    func build_custom_scheme_url_for_settings_debug() {
        let route = IncomesRoute.settingsDebug
        let url = IncomesRouteURLBuilder.customSchemeURL(for: route)
        #expect(
            url?.absoluteString == "incomes://v1/settings/debug"
        )
    }

    @Test
    func build_custom_scheme_url_for_year_summary() {
        let route = IncomesRoute.yearSummary(2_026)
        let url = IncomesRouteURLBuilder.customSchemeURL(for: route)
        #expect(
            url?.absoluteString == "incomes://v1/year-summary/2026"
        )
    }
}
