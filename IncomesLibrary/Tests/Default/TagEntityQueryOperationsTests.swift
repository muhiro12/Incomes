@testable import IncomesLibrary
import SwiftData
import Testing

struct TagEntityQueryOperationsTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func getByIDs_returns_matching_tags() throws {
        let firstTag = try Tag.create(context: context, name: "2026", type: .year)
        _ = try Tag.create(context: context, name: "202601", type: .yearMonth)
        let thirdTag = try Tag.create(context: context, name: "Coffee", type: .content)
        let ids = try [firstTag, thirdTag].map { tag in
            try PersistentIdentifierCoder.encode(tag.id)
        }

        let tags = try TagQueryOperations.getByIDs(
            context: context,
            ids: ids
        )

        #expect(Set(tags.map(\.name)) == ["2026", "Coffee"])
    }

    @Test
    func representativeTags_returns_one_tag_for_each_user_facing_type() throws {
        _ = try Tag.create(context: context, name: "2026", type: .year)
        _ = try Tag.create(context: context, name: "202601", type: .yearMonth)
        _ = try Tag.create(context: context, name: "Coffee", type: .content)
        _ = try Tag.create(context: context, name: "Food", type: .category)
        _ = try Tag.create(context: context, name: "Debug", type: .debug)

        let tags = try TagQueryOperations.representativeTags(context: context)

        #expect(tags.map(\.type) == [.year, .yearMonth, .content, .category])
    }

    @Test
    func representativeTags_matching_query_returns_one_matching_tag_per_type() throws {
        _ = try Tag.create(context: context, name: "2026", type: .year)
        _ = try Tag.create(context: context, name: "202601", type: .yearMonth)
        _ = try Tag.create(context: context, name: "Coffee", type: .content)
        _ = try Tag.create(context: context, name: "Coffee Shop", type: .category)
        _ = try Tag.create(context: context, name: "Tea", type: .content)

        let tags = try TagQueryOperations.representativeTags(
            context: context,
            matching: "Coffee"
        )

        #expect(tags.map(\.type) == [.content, .category])
        #expect(Set(tags.map(\.name)) == ["Coffee", "Coffee Shop"])
    }
}
