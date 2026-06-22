import Foundation
@testable import IncomesLibrary
import Testing

struct IncomesDeepLinkURLBuilderTests {
    @Test
    func route_url_builds_home_url() {
        let url = IncomesDeepLinkURLBuilder.routeURL(for: .home)
        #expect(
            url?.absoluteString == "https://muhiro12.github.io/Incomes/home"
        )
    }

    @Test
    func preferred_url_builds_home_url() {
        let url = IncomesDeepLinkURLBuilder.preferredURL(for: .home)
        #expect(
            url.absoluteString == "https://muhiro12.github.io/Incomes/home"
        )
    }

    @Test
    func preferred_url_builds_year_url() {
        let url = IncomesDeepLinkURLBuilder.preferredURL(for: .year(2_026))
        #expect(
            url.absoluteString == "https://muhiro12.github.io/Incomes/year/2026"
        )
    }

    @Test
    func preferred_url_builds_year_summary_url() {
        let url = IncomesDeepLinkURLBuilder.preferredURL(for: .yearSummary(2_026))
        #expect(
            url.absoluteString == "https://muhiro12.github.io/Incomes/year-summary/2026"
        )
    }

    @Test
    func route_url_returns_nil_for_unparseable_route() {
        let yearURL = IncomesDeepLinkURLBuilder.routeURL(for: .year(0))
        let monthURL = IncomesDeepLinkURLBuilder.routeURL(
            for: .month(year: 2_026, month: 13)
        )

        #expect(yearURL == nil)
        #expect(monthURL == nil)
    }

    @Test
    func preferred_url_falls_back_to_home_for_unparseable_route() {
        let url = IncomesDeepLinkURLBuilder.preferredURL(for: .year(0))

        #expect(
            url.absoluteString == "https://muhiro12.github.io/Incomes/home"
        )
    }

    @Test
    func route_url_builds_item_url() {
        let url = IncomesDeepLinkURLBuilder.itemURL(for: "item-id")
        #expect(
            url?.absoluteString == "https://muhiro12.github.io/Incomes/item?id=item-id"
        )
    }

    @Test
    func preferred_url_builds_item_url() {
        let url = IncomesDeepLinkURLBuilder.preferredItemURL(for: "item-id")
        #expect(
            url.absoluteString == "https://muhiro12.github.io/Incomes/item?id=item-id"
        )
    }

    @Test
    func item_url_returns_nil_for_empty_identifier() {
        let url = IncomesDeepLinkURLBuilder.itemURL(for: "")

        #expect(url == nil)
    }

    @Test
    func preferred_item_url_falls_back_to_home_for_empty_identifier() {
        let url = IncomesDeepLinkURLBuilder.preferredItemURL(for: "")

        #expect(
            url.absoluteString == "https://muhiro12.github.io/Incomes/home"
        )
    }

    @Test
    func month_url_builds_month_route_from_date_components() {
        var calendar = Calendar(identifier: .gregorian)
        guard let utcTimeZone = TimeZone(secondsFromGMT: 0) else {
            Issue.record("Failed to construct UTC time zone")
            return
        }
        calendar.timeZone = utcTimeZone
        guard let date = calendar.date(
            from: .init(
                year: 2_026,
                month: 7,
                day: 1,
                hour: 0,
                minute: 0,
                second: 0
            )
        ) else {
            Issue.record("Failed to construct test date")
            return
        }

        let url = IncomesDeepLinkURLBuilder.monthURL(
            for: date,
            calendar: calendar
        )

        #expect(
            url?.absoluteString == "https://muhiro12.github.io/Incomes/month/2026-07"
        )
    }

    @Test
    func preferred_month_url_builds_month_route_from_date_components() {
        var calendar = Calendar(identifier: .gregorian)
        guard let utcTimeZone = TimeZone(secondsFromGMT: 0) else {
            Issue.record("Failed to construct UTC time zone")
            return
        }
        calendar.timeZone = utcTimeZone
        guard let date = calendar.date(
            from: .init(
                year: 2_026,
                month: 7,
                day: 1,
                hour: 0,
                minute: 0,
                second: 0
            )
        ) else {
            Issue.record("Failed to construct test date")
            return
        }

        let url = IncomesDeepLinkURLBuilder.preferredMonthURL(
            for: date,
            calendar: calendar
        )

        #expect(
            url.absoluteString == "https://muhiro12.github.io/Incomes/month/2026-07"
        )
    }
}
