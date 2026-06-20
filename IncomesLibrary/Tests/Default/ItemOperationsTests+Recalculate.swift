import Foundation
@testable import IncomesLibrary
import Testing

extension ItemOperationsTests {
    // MARK: - Recalculate

    @Test
    func recalculate_recomputes_balance_after_update() throws {
        let item = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T00:00:00Z"),
                content: "content",
                income: 100,
                outgo: 50,
                category: "category",
                priority: 0
            ),
            repeatCount: 1
        )
        try updateItem(
            context: context,
            item: item,
            input: .init(
                date: item.localDate,
                content: item.content,
                income: item.income,
                outgo: 90,
                category: item.category?.name ?? "",
                priority: 0
            )
        )
        try ItemBalanceOperations.recalculate(
            context: context,
            date: shiftedDate("1999-12-01T00:00:00Z")
        )
        let result = try #require(fetchItems(context).first)
        #expect(result.balance == 10)
    }
}
