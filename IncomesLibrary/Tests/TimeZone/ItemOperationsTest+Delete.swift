import Foundation
@testable import IncomesLibrary
import Testing

extension ItemOperationsTest {
    // MARK: - Delete

    @Test("delete removes the specified item", arguments: timeZones)
    func delete(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-04-01T00:00:00Z"),
                content: "ToDelete",
                income: 100,
                outgo: 0,
                category: "Temp",
                priority: 0
            )
        )
        let item = try #require(fetchItems(context).first)
        try ItemDeletionOperations.delete(
            context: context,
            item: item
        )
        let items = try context.fetch(.items(.all))
        #expect(items.isEmpty)
    }

    @Test("delete with multiple items removes only specified ones", arguments: timeZones)
    func deleteMultipleItems(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-01-01T00:00:00Z"),
                content: "KeepMe",
                income: 100,
                outgo: 0,
                category: "General",
                priority: 0
            )
        )
        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-01-02T00:00:00Z"),
                content: "RemoveMe",
                income: 100,
                outgo: 0,
                category: "General",
                priority: 0
            )
        )
        let allItems = try context.fetch(.items(.all))
        let toDelete = allItems.filter { item in
            item.content == "RemoveMe"
        }
        try toDelete.forEach { item in
            try ItemDeletionOperations.delete(context: context, item: item)
        }

        let remaining = try context.fetch(.items(.all))
        #expect(remaining.count == 1)
        #expect(remaining.first?.content == "KeepMe")
    }

    @Test("deleteAll clears all items", arguments: timeZones)
    func deleteAll(_ timeZone: TimeZone) throws {
        TimeZone.ReferenceType.default = timeZone

        _ = try createTestItem(
            input: .init(
                date: isoDate("2024-01-01T00:00:00Z"),
                content: "DeleteMe",
                income: 0,
                outgo: 100,
                category: "Tmp",
                priority: 0
            )
        )
        #expect(!fetchItems(context).isEmpty)
        try ItemDeletionOperations.deleteAll(context: context)
        #expect(fetchItems(context).isEmpty)
    }
}
