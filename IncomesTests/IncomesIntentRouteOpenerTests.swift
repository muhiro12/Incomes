import Foundation
@testable import Incomes
import IncomesLibrary
import MHDeepLinking
import Testing

@MainActor
struct IncomesIntentRouteOpenerTests {
    @Test
    func home_intent_stores_home_route_in_intent_store() throws {
        let intent = IncomesIntentRouteOpener.homeIntent()
        IncomesIntentRouteStore.source?.clear()
        _ = intent.perform()
        let url = try #require(IncomesIntentRouteStore.source?.consumeLatest())
        let route = try #require(
            IncomesRouteParser.parse(url: url)
        )

        #expect(route == .home)
    }

    @Test
    func month_intent_stores_month_route_in_intent_store() throws {
        let date = Calendar.current.date(
            from: .init(year: 2_026, month: 7, day: 1)
        ) ?? .now
        let intent = IncomesIntentRouteOpener.monthIntent(for: date)
        IncomesIntentRouteStore.source?.clear()
        _ = intent.perform()
        let url = try #require(IncomesIntentRouteStore.source?.consumeLatest())
        let route = try #require(
            IncomesRouteParser.parse(url: url)
        )

        #expect(route == .month(year: 2_026, month: 7))
    }
}
