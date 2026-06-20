import Foundation
@testable import IncomesLibrary
import Testing

extension ItemTest {
    // MARK: - Comparable

    @Test("Comparable order respects content name when priorities match", arguments: timeZones)
    func comparableNameOrderIsExpected(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let baseDate = shiftedDate("2000-01-01T12:00:00Z")
        let firstItem = try Item.create(
            context: context,
            values: .init(
                date: baseDate,
                content: "Item A",
                income: 0,
                outgo: 10,
                category: "category",
                priority: 0
            ),
            repeatID: UUID()
        )
        let secondItem = try Item.create(
            context: context,
            values: .init(
                date: baseDate,
                content: "Item B",
                income: 0,
                outgo: 20,
                category: "category",
                priority: 0
            ),
            repeatID: UUID()
        )

        let items = [firstItem, secondItem].sorted()
        #expect(items.count == 2)
        #expect(items[0].content == "Item B")
        #expect(items[1].content == "Item A")
    }

    @Test("Comparable order is as expected when priorities share the same date", arguments: timeZones)
    func comparablePriorityOrderIsExpected(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let baseDate = shiftedDate("2000-01-01T12:00:00Z")
        let lowPriorityItem = try Item.create(
            context: context,
            values: .init(
                date: baseDate,
                content: "Item A",
                income: 0,
                outgo: 50,
                category: "category",
                priority: 0
            ),
            repeatID: UUID()
        )
        let highPriorityItem = try Item.create(
            context: context,
            values: .init(
                date: baseDate,
                content: "Item B",
                income: 100,
                outgo: 0,
                category: "category",
                priority: 1
            ),
            repeatID: UUID()
        )

        let items = [lowPriorityItem, highPriorityItem].sorted()
        #expect(items.count == 2)
        #expect(items[0].content == "Item A")
        #expect(items[1].content == "Item B")
    }

    @Test("Comparable order is consistent between priority 0/1 and 1/2", arguments: timeZones)
    func comparablePriorityOrderIsConsistent(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        let baseDate = shiftedDate("2000-01-01T12:00:00Z")
        let firstItem = try Item.create(
            context: context,
            values: .init(
                date: baseDate,
                content: "Item A",
                income: 0,
                outgo: 10,
                category: "category",
                priority: 1
            ),
            repeatID: UUID()
        )
        let secondItem = try Item.create(
            context: context,
            values: .init(
                date: baseDate,
                content: "Item B",
                income: 0,
                outgo: 20,
                category: "category",
                priority: 2
            ),
            repeatID: UUID()
        )

        let items = [firstItem, secondItem].sorted()
        #expect(items.count == 2)
        #expect(items[0].content == "Item A")
        #expect(items[1].content == "Item B")
    }
}
