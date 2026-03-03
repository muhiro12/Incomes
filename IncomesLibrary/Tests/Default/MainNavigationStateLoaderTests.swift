import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct MainNavigationStateLoaderTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func load_returns_nil_tags_when_store_is_empty() throws {
        let state = try MainNavigationStateLoader.load(
            context: context
        )
        #expect(state.yearTag == nil)
        #expect(state.yearMonthTag == nil)
    }

    @Test
    func load_resolves_year_and_year_month_tags_for_date() throws {
        let date = shiftedDate("2002-04-05T12:00:00Z")
        _ = try Tag.create(
            context: context,
            name: date.stringValueWithoutLocale(.yyyy),
            type: .year
        )
        _ = try Tag.create(
            context: context,
            name: date.stringValueWithoutLocale(.yyyyMM),
            type: .yearMonth
        )

        let state = try MainNavigationStateLoader.load(
            context: context,
            date: date
        )
        let yearTag = try #require(state.yearTag)
        let yearMonthTag = try #require(state.yearMonthTag)

        #expect(yearTag.name == date.stringValueWithoutLocale(.yyyy))
        #expect(yearTag.type == .year)
        #expect(yearMonthTag.name == date.stringValueWithoutLocale(.yyyyMM))
        #expect(yearMonthTag.type == .yearMonth)
    }
}
