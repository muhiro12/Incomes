import Foundation
@testable import IncomesLibrary
import Testing

struct IncomesRouteURLRoundTripTests {
    @Test
    func custom_scheme_route_urls_round_trip_through_parser() throws {
        try assertRoundTripURLs { route in
            IncomesRouteURLBuilder.customSchemeURL(for: route)
        }
    }

    @Test
    func universal_link_route_urls_round_trip_through_parser() throws {
        try assertRoundTripURLs { route in
            IncomesRouteURLBuilder.universalLinkURL(for: route)
        }
    }

    private func assertRoundTripURLs(
        using makeURL: (IncomesRoute) -> URL?
    ) throws {
        for route in roundTripRoutes() {
            let url = try #require(makeURL(route))
            let parsedRoute = IncomesRouteParser.parse(url: url)

            #expect(parsedRoute == route)
        }
    }

    private func roundTripRoutes() -> [IncomesRoute] {
        [
            .home,
            .settings,
            .settingsSubscription,
            .settingsLicense,
            .settingsDebug,
            .yearSummary(2_026),
            .yearlyDuplication,
            .duplicateTags,
            .orphanTags,
            .year(2_026),
            .month(year: 2_026, month: 4),
            .item("item-id"),
            .search(query: "rent"),
            .search(query: nil)
        ]
    }
}
