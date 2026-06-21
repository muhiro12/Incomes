import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct ItemFormInitialDateResolverTests {
    let context: ModelContext
    let calendar: Calendar

    init() {
        context = testContext
        calendar = .current
    }

    @Test
    func date_returns_current_date_for_current_year_tag() throws {
        let tag = try Tag.create(context: context, name: "2024", type: .year)
        let currentDate = localDate(year: 2_024, month: 6, day: 10)

        let date = ItemFormInitialDateResolver.date(
            for: tag,
            currentDate: currentDate,
            calendar: calendar
        )

        #expect(date == currentDate)
    }

    @Test
    func date_returns_tag_date_for_different_year_tag() throws {
        let tag = try Tag.create(context: context, name: "2023", type: .year)
        let currentDate = localDate(year: 2_024, month: 6, day: 10)

        let date = ItemFormInitialDateResolver.date(
            for: tag,
            currentDate: currentDate,
            calendar: calendar
        )

        let year = calendar.component(.year, from: date)
        #expect(year == 2_023)
    }

    @Test
    func date_returns_current_date_for_current_year_month_tag() throws {
        let tag = try Tag.create(context: context, name: "202406", type: .yearMonth)
        let currentDate = localDate(year: 2_024, month: 6, day: 10)

        let date = ItemFormInitialDateResolver.date(
            for: tag,
            currentDate: currentDate,
            calendar: calendar
        )

        #expect(date == currentDate)
    }

    @Test
    func date_returns_tag_date_for_different_year_month_tag() throws {
        let tag = try Tag.create(context: context, name: "202405", type: .yearMonth)
        let currentDate = localDate(year: 2_024, month: 6, day: 10)

        let date = ItemFormInitialDateResolver.date(
            for: tag,
            currentDate: currentDate,
            calendar: calendar
        )

        let components = calendar.dateComponents([.year, .month], from: date)
        #expect(components.year == 2_024)
        #expect(components.month == 5)
    }

    @Test
    func date_returns_current_date_for_non_date_tags() throws {
        let tag = try Tag.create(context: context, name: "Food", type: .category)
        let currentDate = localDate(year: 2_024, month: 6, day: 10)

        let date = ItemFormInitialDateResolver.date(
            for: tag,
            currentDate: currentDate,
            calendar: calendar
        )

        #expect(date == currentDate)
    }
}

private extension ItemFormInitialDateResolverTests {
    func localDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day

        guard let date = calendar.date(from: components) else {
            preconditionFailure("Invalid date components")
        }
        return date
    }
}
