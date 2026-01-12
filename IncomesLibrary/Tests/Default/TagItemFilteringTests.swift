import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct TagItemFilteringTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func items_filters_by_year_string_and_sorts() throws {
        let firstDate = shiftedDate("2001-01-01T00:00:00Z")
        let secondDate = shiftedDate("2001-03-01T00:00:00Z")
        let thirdDate = shiftedDate("2002-01-01T00:00:00Z")

        let firstItem = try Item.create(
            context: context,
            date: firstDate,
            content: "First",
            income: 0,
            outgo: 1,
            category: "Category",
            repeatID: .init()
        )
        let secondItem = try Item.create(
            context: context,
            date: secondDate,
            content: "Second",
            income: 0,
            outgo: 2,
            category: "Category",
            repeatID: .init()
        )
        _ = try Item.create(
            context: context,
            date: thirdDate,
            content: "Third",
            income: 0,
            outgo: 3,
            category: "Category",
            repeatID: .init()
        )

        let tag = try #require(
            firstItem.tags?.first { tag in
                tag.type == .category
            }
        )

        let items = TagItemFiltering.items(
            for: tag,
            yearString: firstDate.stringValueWithoutLocale(.yyyy)
        )

        #expect(items.count == 2)
        #expect(items.first?.id == secondItem.id)
        #expect(items.last?.id == firstItem.id)
    }
}
