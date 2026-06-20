import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct ItemDerivedTagTest {
    let context = testContext

    @Test("modify keeps only the updated derived tags on the item")
    func modifyKeepsOnlyUpdatedDerivedTags() throws {
        let item = try Item.create(
            context: context,
            values: .init(
                date: shiftedDate("2024-01-01T00:00:00Z"),
                content: "Old Content",
                income: 100,
                outgo: 20,
                category: "Old Category",
                priority: 0
            ),
            repeatID: UUID()
        )

        try item.modify(
            values: .init(
                date: shiftedDate("2025-02-01T00:00:00Z"),
                content: "New Content",
                income: 200,
                outgo: 50,
                category: "New Category",
                priority: 1
            ),
            repeatID: item.repeatID
        )

        let tags = try #require(item.tags)
        #expect(tags.count == 4)
        #expect(tags.contains { tag in
            tag.name == "2025" && tag.type == .year
        })
        #expect(tags.contains { tag in
            tag.name == "202502" && tag.type == .yearMonth
        })
        #expect(tags.contains { tag in
            tag.name == "New Content" && tag.type == .content
        })
        #expect(tags.contains { tag in
            tag.name == "New Category" && tag.type == .category
        })
        #expect(tags.contains { tag in
            tag.name == "2024" && tag.type == .year
        } == false)
        #expect(tags.contains { tag in
            tag.name == "202401" && tag.type == .yearMonth
        } == false)
        #expect(tags.contains { tag in
            tag.name == "Old Content" && tag.type == .content
        } == false)
        #expect(tags.contains { tag in
            tag.name == "Old Category" && tag.type == .category
        } == false)
    }
}
