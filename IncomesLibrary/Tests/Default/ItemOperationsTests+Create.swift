import Foundation
@testable import IncomesLibrary
import Testing

extension ItemOperationsTests {
    // MARK: - Create

    @Test
    func create_creates_item() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "content",
                income: 200,
                outgo: 100,
                category: "category",
                priority: 0
            ),
            repeatCount: 1
        )
        let result = try #require(fetchItems(context).first)
        #expect(result.utcDate == isoDate("2000-01-01T00:00:00Z"))
        #expect(result.content == "content")
        #expect(result.balance == 100)
    }

    @Test
    func create_creates_repeating_items() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "content",
                income: 200,
                outgo: 100,
                category: "category",
                priority: 0
            ),
            repeatCount: 3
        )
        let items = fetchItems(context)
        #expect(items.count == 3)
        #expect(Set(items.map(\.repeatID)).count == 1)
    }

    @Test
    func create_creates_items_for_selected_months() throws {
        let selections: Set<RepeatMonthSelection> = [
            .init(year: 2_000, month: 4),
            .init(year: 2_000, month: 6),
            .init(year: 2_000, month: 7)
        ]
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-04-03T12:00:00Z"),
                content: "content",
                income: 200,
                outgo: 100,
                category: "category",
                priority: 0
            ),
            repeatMonthSelections: selections
        )
        let items = fetchItems(context)
        #expect(items.count == 3)
        #expect(Set(items.map(\.repeatID)).count == 1)

        let calendar = Calendar.current
        let months = Set(items.map { item in
            calendar.component(.month, from: item.localDate)
        })
        let expectedMonths: Set<Int> = [4, 6, 7]
        #expect(months == expectedMonths)
    }

    @Test
    func create_creates_items_for_base_and_next_year() throws {
        let selections: Set<RepeatMonthSelection> = [
            .init(year: 2_000, month: 2),
            .init(year: 2_001, month: 1)
        ]
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-11-03T12:00:00Z"),
                content: "content",
                income: 200,
                outgo: 100,
                category: "category",
                priority: 0
            ),
            repeatMonthSelections: selections
        )
        let items = fetchItems(context)
        #expect(items.count == 3)

        let calendar = Calendar.current
        let yearMonthPairs = Set(items.map { item in
            let year = calendar.component(.year, from: item.localDate)
            let month = calendar.component(.month, from: item.localDate)
            return "\(year)-\(month)"
        })
        let expectedPairs: Set<String> = ["2000-2", "2000-11", "2001-1"]
        #expect(yearMonthPairs == expectedPairs)
    }

    @Test
    func create_includes_base_month_when_not_selected() throws {
        let selections: Set<RepeatMonthSelection> = [
            .init(year: 2_000, month: 1),
            .init(year: 2_000, month: 3)
        ]
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-02-03T12:00:00Z"),
                content: "content",
                income: 200,
                outgo: 100,
                category: "category",
                priority: 0
            ),
            repeatMonthSelections: selections
        )
        let items = fetchItems(context)
        #expect(items.count == 3)

        let calendar = Calendar.current
        let months = Set(items.map { item in
            calendar.component(.month, from: item.localDate)
        })
        let expectedMonths: Set<Int> = [1, 2, 3]
        #expect(months == expectedMonths)
    }

    @Test
    func create_ignores_invalid_months_and_years() throws {
        let selections: Set<RepeatMonthSelection> = [
            .init(year: 2_000, month: 4),
            .init(year: 2_000, month: 0),
            .init(year: 2_000, month: 13),
            .init(year: 1_999, month: 6),
            .init(year: 2_002, month: 7)
        ]
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-04-03T12:00:00Z"),
                content: "content",
                income: 200,
                outgo: 100,
                category: "category",
                priority: 0
            ),
            repeatMonthSelections: selections
        )
        let items = fetchItems(context)
        #expect(items.count == 1)

        let calendar = Calendar.current
        let yearMonthPairs = Set(items.map { item in
            let year = calendar.component(.year, from: item.localDate)
            let month = calendar.component(.month, from: item.localDate)
            return "\(year)-\(month)"
        })
        let expectedPairs: Set<String> = ["2000-4"]
        #expect(yearMonthPairs == expectedPairs)
    }

    @Test
    func create_with_empty_selections_creates_only_base_month() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-04-03T12:00:00Z"),
                content: "content",
                income: 200,
                outgo: 100,
                category: "category",
                priority: 0
            ),
            repeatMonthSelections: []
        )
        let items = fetchItems(context)
        #expect(items.count == 1)

        let calendar = Calendar.current
        let yearMonthPairs = Set(items.map { item in
            let year = calendar.component(.year, from: item.localDate)
            let month = calendar.component(.month, from: item.localDate)
            return "\(year)-\(month)"
        })
        let expectedPairs: Set<String> = ["2000-4"]
        #expect(yearMonthPairs == expectedPairs)
    }
}
