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
}
