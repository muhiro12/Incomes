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
    func load_sets_intro_presented_when_empty() throws {
        let state = try MainNavigationStateLoader.load(
            context: context
        )
        #expect(state.isIntroductionPresented == true)
    }

    @Test
    func load_sets_intro_presented_false_when_items_exist() throws {
        _ = try Item.create(
            context: context,
            date: shiftedDate("2001-02-03T12:00:00Z"),
            content: "Sample",
            income: 100,
            outgo: 0,
            category: "Test",
            priority: 0,
            repeatID: .init()
        )
        let state = try MainNavigationStateLoader.load(
            context: context
        )
        #expect(state.isIntroductionPresented == false)
    }

    @Test
    func load_resolves_year_and_year_month_tags_for_date() throws {
        let date = shiftedDate("2002-04-05T12:00:00Z")
        _ = try Item.create(
            context: context,
            date: date,
            content: "Content",
            income: 0,
            outgo: 50,
            category: "Category",
            priority: 0,
            repeatID: .init()
        )

        let state = try MainNavigationStateLoader.load(
            context: context,
            date: date
        )
        let yearTag = try #require(state.yearTag)
        let yearMonthTag = try #require(state.yearMonthTag)

        #expect(yearTag.name == date.stableStringValueWithoutLocale(.yyyy))
        #expect(yearTag.type == .year)
        #expect(yearMonthTag.name == date.stableStringValueWithoutLocale(.yyyyMM))
        #expect(yearMonthTag.type == .yearMonth)
    }
}
