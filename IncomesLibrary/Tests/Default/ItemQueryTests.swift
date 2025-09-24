import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct ItemQueryTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func sameMonth_returns_expected_items() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-01-05T12:00:00Z"),
            content: "January",
            income: 100,
            outgo: 0,
            category: "Test",
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-02-10T12:00:00Z"),
            content: "February",
            income: 200,
            outgo: 0,
            category: "Test",
            repeatCount: 1
        )

        var query = ItemQuery()
        query.date = .sameMonth(shiftedDate("2000-01-15T00:00:00Z"))
        let results = try ItemService.items(context: context, query: query)
        #expect(results.count == 1)
        #expect(results.first?.content == "January")
    }

    @Test
    func incomeNonZero_filters_only_income_items() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-03-01T00:00:00Z"),
            content: "Income",
            income: 10,
            outgo: 0,
            category: "Test",
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-03-02T00:00:00Z"),
            content: "Outgo",
            income: 0,
            outgo: 5,
            category: "Test",
            repeatCount: 1
        )

        var query = ItemQuery()
        query.date = .sameMonth(shiftedDate("2000-03-15T00:00:00Z"))
        query.incomeNonZero = true
        let results = try ItemService.items(context: context, query: query)
        #expect(results.count == 1)
        #expect(results.first?.content == "Income")
    }

    @Test
    func outgo_range_filters_between() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-04-01T00:00:00Z"),
            content: "Low",
            income: 0,
            outgo: 10,
            category: "Test",
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-04-02T00:00:00Z"),
            content: "Mid",
            income: 0,
            outgo: 50,
            category: "Test",
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-04-03T00:00:00Z"),
            content: "High",
            income: 0,
            outgo: 100,
            category: "Test",
            repeatCount: 1
        )

        var query = ItemQuery()
        query.date = .sameMonth(shiftedDate("2000-04-15T00:00:00Z"))
        query.outgoMin = 20
        query.outgoMax = 80
        let results = try ItemService.items(context: context, query: query)
        #expect(results.count == 1)
        #expect(results.first?.content == "Mid")
    }

    @Test
    func contentContains_filters_by_substring() throws {
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-05-01T00:00:00Z"),
            content: "Grocery Store",
            income: 0,
            outgo: 20,
            category: "Living",
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-05-02T00:00:00Z"),
            content: "Gas Station",
            income: 0,
            outgo: 30,
            category: "Car",
            repeatCount: 1
        )

        var query = ItemQuery()
        query.date = .sameMonth(shiftedDate("2000-05-15T00:00:00Z"))
        query.contentContains = "Grocery"
        let results = try ItemService.items(context: context, query: query)
        #expect(results.count == 1)
        #expect(results.first?.content == "Grocery Store")
    }

    @Test
    func combined_filters_work_together() throws {
        // Two items on same day, only one matches both income range and content
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-06-10T12:00:00Z"),
            content: "Freelance",
            income: 300,
            outgo: 0,
            category: "Salary",
            repeatCount: 1
        )
        _ = try ItemService.create(
            context: context,
            date: shiftedDate("2000-06-10T12:00:00Z"),
            content: "Refund",
            income: 50,
            outgo: 0,
            category: "Other",
            repeatCount: 1
        )

        var query = ItemQuery()
        query.date = .sameDay(shiftedDate("2000-06-10T00:00:00Z"))
        query.contentContains = "Free"
        query.incomeMin = 200
        query.incomeMax = 400
        let results = try ItemService.items(context: context, query: query)
        #expect(results.count == 1)
        #expect(results.first?.content == "Freelance")
    }
}
