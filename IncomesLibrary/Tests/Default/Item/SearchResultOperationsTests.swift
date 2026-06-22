import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct SearchResultOperationsTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func sections_group_items_by_local_month_from_newest_to_oldest() throws {
        let januaryItem = try makeItem(
            dateString: "2024-01-15T12:00:00Z",
            content: "January"
        )
        let marchItem = try makeItem(
            dateString: "2024-03-01T12:00:00Z",
            content: "March"
        )
        let februaryItem = try makeItem(
            dateString: "2024-02-10T12:00:00Z",
            content: "February"
        )

        let sections = SearchResultOperations.sections(
            for: [januaryItem, marchItem, februaryItem]
        )

        #expect(sections.map(\.items.first?.content) == ["March", "February", "January"])
        #expect(sections.map(\.month) == [
            Calendar.current.startOfMonth(for: marchItem.localDate),
            Calendar.current.startOfMonth(for: februaryItem.localDate),
            Calendar.current.startOfMonth(for: januaryItem.localDate)
        ])
    }

    @Test
    func sections_preserve_item_order_within_month() throws {
        let secondItem = try makeItem(
            dateString: "2024-01-20T12:00:00Z",
            content: "Second"
        )
        let firstItem = try makeItem(
            dateString: "2024-01-10T12:00:00Z",
            content: "First"
        )

        let sections = SearchResultOperations.sections(
            for: [secondItem, firstItem]
        )

        #expect(sections.map { section in
            section.items.map(\.content)
        } == [["Second", "First"]])
    }

    @Test
    func sections_return_empty_for_empty_items() {
        let sections = SearchResultOperations.sections(for: [])

        #expect(sections.isEmpty)
    }

    @Test
    func currency_predicate_parses_grouped_amounts() {
        let predicate = SearchResultOperations.currencyPredicate(
            target: .income,
            minimumText: "1,000",
            maximumText: "2,500.50"
        )

        #expect(predicate == .incomeIsBetween(
            min: 1_000,
            max: Decimal(string: "2500.50") ?? .zero
        ))
    }
}

private extension SearchResultOperationsTests {
    enum TestAmount {
        static let income: Decimal = 100
        static let outgo: Decimal = .zero
    }

    func makeItem(
        dateString: String,
        content: String
    ) throws -> Item {
        try createItem(
            context: context,
            input: .init(
                date: shiftedDate(dateString),
                content: content,
                income: TestAmount.income,
                outgo: TestAmount.outgo,
                category: "Test",
                priority: 0
            )
        )
    }
}
