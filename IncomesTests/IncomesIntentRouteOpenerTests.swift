import Foundation
@testable import Incomes
import IncomesLibrary
import MHDeepLinking
import Testing

@MainActor
struct IncomesIntentRouteOpenerTests {
    @Test
    func home_intent_uses_home_url() throws {
        let intent = IncomesIntentRouteOpener.homeIntent()
        IncomesIntentRouteStore.source?.clear()
        _ = intent.perform()
        let url = try #require(IncomesIntentRouteStore.source?.consumeLatest())

        #expect(url == IncomesDeepLinkURLBuilder.homeURL())
    }

    @Test
    func month_intent_uses_preferred_month_url() throws {
        let date = Calendar.current.date(
            from: .init(year: 2_026, month: 7, day: 1)
        ) ?? .now
        let intent = IncomesIntentRouteOpener.monthIntent(for: date)
        IncomesIntentRouteStore.source?.clear()
        _ = intent.perform()
        let url = try #require(IncomesIntentRouteStore.source?.consumeLatest())

        #expect(url == IncomesDeepLinkURLBuilder.preferredMonthURL(for: date))
    }
}
