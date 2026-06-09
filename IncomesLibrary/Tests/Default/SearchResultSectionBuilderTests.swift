import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct SearchResultSectionBuilderTests {
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

        let sections = SearchResultSectionBuilder.sections(
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

        let sections = SearchResultSectionBuilder.sections(
            for: [secondItem, firstItem]
        )

        #expect(sections.map { section in
            section.items.map(\.content)
        } == [["Second", "First"]])
    }

    @Test
    func sections_return_empty_for_empty_items() {
        let sections = SearchResultSectionBuilder.sections(for: [])

        #expect(sections.isEmpty)
    }
}

private extension SearchResultSectionBuilderTests {
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
            date: shiftedDate(dateString),
            content: content,
            income: TestAmount.income,
            outgo: TestAmount.outgo,
            category: "Test",
            priority: 0
        )
    }
}
