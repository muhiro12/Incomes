import Foundation
@testable import IncomesLibrary
import Testing

extension ItemOperationsTests {
    // MARK: - Next / Previous

    @Test
    func nextItem_returns_next_item() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "A",
                income: 0,
                outgo: 100,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-02-01T12:00:00Z"),
                content: "B",
                income: 500,
                outgo: 200,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        let item = try #require(
            try ItemQueryOperations.nextItem(
                context: context,
                date: shiftedDate("2000-01-15T00:00:00Z")
            )
        )
        #expect(item.content == "B")
        #expect(item.localDate == shiftedDate("2000-02-01T00:00:00Z"))
        #expect(item.netIncome == 300)
    }

    @Test
    func nextItem_returns_item_when_date_is_exact() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-03-01T00:00:00Z"),
                content: "Exact",
                income: 10,
                outgo: 0,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        let result = try ItemQueryOperations.nextItem(
            context: context,
            date: shiftedDate("2000-03-01T00:00:00Z")
        )
        #expect(result?.content == "Exact")
    }

    @Test
    func nextItem_returns_nil_when_not_found() throws {
        let result = try ItemQueryOperations.nextItem(
            context: context,
            date: shiftedDate("2001-01-01T00:00:00Z")
        )
        #expect(result == nil)
    }

    @Test
    func previousItem_returns_previous_item() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "A",
                income: 700,
                outgo: 200,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-02-01T12:00:00Z"),
                content: "B",
                income: 500,
                outgo: 200,
                category: "Test",
                priority: 0
            ),
            repeatCount: 1
        )
        let item = try #require(
            try ItemQueryOperations.previousItem(
                context: context,
                date: shiftedDate("2000-02-15T00:00:00Z")
            )
        )
        #expect(item.content == "B")
        #expect(item.localDate == shiftedDate("2000-02-01T00:00:00Z"))
        #expect(item.netIncome == 300)
    }

    @Test
    func previousItem_returns_nil_when_not_found() throws {
        let result = try ItemQueryOperations.previousItem(
            context: context,
            date: shiftedDate("1999-01-01T00:00:00Z")
        )
        #expect(result == nil)
    }
}
