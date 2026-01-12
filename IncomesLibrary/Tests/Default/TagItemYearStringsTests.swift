import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct TagItemYearStringsTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func yearStrings_returns_unique_years_in_descending_order() throws {
        _ = try Item.create(
            context: context,
            date: shiftedDate("2002-01-01T00:00:00Z"),
            content: "First",
            income: 0,
            outgo: 1,
            category: "Category",
            repeatID: .init()
        )
        _ = try Item.create(
            context: context,
            date: shiftedDate("2001-01-01T00:00:00Z"),
            content: "Second",
            income: 0,
            outgo: 2,
            category: "Category",
            repeatID: .init()
        )
        _ = try Item.create(
            context: context,
            date: shiftedDate("2001-06-01T00:00:00Z"),
            content: "Third",
            income: 0,
            outgo: 3,
            category: "Category",
            repeatID: .init()
        )

        let tag = try #require(
            try context.fetchFirst(.tags(.typeIs(.category)))
        )

        let yearStrings = TagService.yearStrings(for: tag)

        #expect(yearStrings == ["2002", "2001"])
    }
}
