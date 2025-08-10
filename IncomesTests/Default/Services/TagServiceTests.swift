import Foundation
@testable import Incomes
import SwiftData
import Testing

@MainActor
struct TagServiceTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    // MARK: - Get

    @Test
    func getAll_returns_all_tags() throws {
        _ = try Tag.create(context: context, name: "A", type: .year)
        _ = try Tag.create(context: context, name: "B", type: .content)
        let tags = try TagService.getAll(context: context)
        #expect(tags.count == 2)
    }

    @Test
    func getByID_returns_matching_tag() throws {
        let model = try Tag.create(context: context, name: "name", type: .content)
        let id = try model.id.base64Encoded()
        let tagEntity = try #require(
            try TagService.getByID(
                context: context,
                id: id
            )
        )
        #expect(tagEntity.name == "name")
        #expect(tagEntity.type == .content)
    }

    @Test
    func getByName_returns_matching_tag() throws {
        _ = try Tag.create(context: context, name: "name", type: .year)
        let tag = try #require(
            try TagService.getByName(
                context: context,
                name: "name",
                type: .year
            )
        )
        #expect(tag.name == "name")
        #expect(tag.type == .year)
    }

    // MARK: - Duplicates

    @Test
    func findDuplicates_returns_first_tag_of_each_duplicate() throws {
        let tag1 = try Tag.createIgnoringDuplicates(context: context, name: "A", type: .year)
        let tag2 = try Tag.createIgnoringDuplicates(context: context, name: "A", type: .year)
        let tag3 = try Tag.createIgnoringDuplicates(context: context, name: "B", type: .yearMonth)
        let tag4 = try Tag.createIgnoringDuplicates(context: context, name: "B", type: .yearMonth)
        let result = try TagService.findDuplicates(
            context: context,
            tags: [tag1, tag2, tag3, tag4].compactMap(TagEntity.init)
        )
        #expect(result.count == 2)
        #expect(result.contains { (try? PersistentIdentifier(base64Encoded: $0.id)) == tag1.id })
        #expect(result.contains { (try? PersistentIdentifier(base64Encoded: $0.id)) == tag3.id })
    }

    @Test
    func hasDuplicates_detects_and_clears_duplicates() throws {
        #expect(try TagService.hasDuplicates(context: context) == false)
        let tag1 = try Tag.createIgnoringDuplicates(context: context, name: "A", type: .year)
        _ = try Tag.createIgnoringDuplicates(context: context, name: "A", type: .year)
        #expect(try TagService.hasDuplicates(context: context) == true)
        try TagService.mergeDuplicates(
            context: context,
            tags: try context.fetch(.tags(.isSameWith(tag1))).compactMap(TagEntity.init)
        )
        #expect(try TagService.hasDuplicates(context: context) == false)
    }

    @Test
    func mergeDuplicates_merges_given_tags() throws {
        let item1 = try Item.create(
            context: context,
            date: .now,
            content: "contentA",
            income: .zero,
            outgo: .zero,
            category: "",
            repeatID: .init()
        )
        let item2 = try Item.create(
            context: context,
            date: .now,
            content: "contentB",
            income: .zero,
            outgo: .zero,
            category: "",
            repeatID: .init()
        )
        let item3 = try Item.create(
            context: context,
            date: .now,
            content: "contentC",
            income: .zero,
            outgo: .zero,
            category: "",
            repeatID: .init()
        )
        let tag1 = item1.tags!.first { $0.type == .content }!
        let tag2 = item2.tags!.first { $0.type == .content }!
        let tag3 = item3.tags!.first { $0.type == .content }!
        try TagService.mergeDuplicates(
            context: context,
            tags: [tag1, tag2, tag3].compactMap(TagEntity.init)
        )
        #expect(try context.fetchCount(.tags(.nameIs("contentA", type: .content))) == 1)
        #expect(try context.fetchCount(.tags(.nameIs("contentB", type: .content))) == 0)
        #expect(try context.fetchCount(.tags(.nameIs("contentC", type: .content))) == 0)
        #expect(item1.tags?.contains(tag1) == true)
        #expect(item2.tags?.contains(tag1) == true)
        #expect(item3.tags?.contains(tag1) == true)
    }

    @Test
    func mergeDuplicates_when_tags_are_duplicated() throws {
        let tag1 = try Tag.createIgnoringDuplicates(context: context, name: "contentA", type: .content)
        let tag2 = try Tag.createIgnoringDuplicates(context: context, name: "contentA", type: .content)
        let tag3 = try Tag.createIgnoringDuplicates(context: context, name: "contentA", type: .content)
        try TagService.mergeDuplicates(
            context: context,
            tags: [tag1, tag2, tag3].compactMap(TagEntity.init)
        )
        #expect(try context.fetchCount(.tags(.nameIs("contentA", type: .content))) == 1)
    }

    @Test
    func resolveDuplicates_removes_all_duplicates() throws {
        let tag1 = try Tag.createIgnoringDuplicates(context: context, name: "A", type: .year)
        _ = try Tag.createIgnoringDuplicates(context: context, name: "A", type: .year)
        _ = try Tag.createIgnoringDuplicates(context: context, name: "A", type: .year)
        let tag4 = try Tag.createIgnoringDuplicates(context: context, name: "B", type: .yearMonth)
        _ = try Tag.createIgnoringDuplicates(context: context, name: "B", type: .yearMonth)
        #expect(try context.fetchCount(.tags(.all)) == 5)
        try TagService.resolveDuplicates(
            context: context,
            tags: [tag1, tag4].compactMap(TagEntity.init)
        )
        #expect(try context.fetchCount(.tags(.all)) == 2)
    }

    // MARK: - Delete

    @Test
    func delete_removes_tag() throws {
        let tag = try Tag.create(context: context, name: "name", type: .year)
        #expect(try context.fetchCount(.tags(.all)) == 1)
        try TagService.delete(context: context, tag: .init(tag)!)
        #expect(try context.fetchCount(.tags(.all)) == 0)
    }

    @Test
    func delete_throws_when_not_found() throws {
        let entity = TagEntity(
            id: UUID().uuidString,
            name: "missing",
            typeID: TagType.content.rawValue
        )
        #expect(throws: Error.self) {
            try TagService.delete(context: context, tag: entity)
        }
    }

    @Test
    func deleteAll_removes_all_tags() throws {
        _ = try Tag.create(context: context, name: "A", type: .content)
        _ = try Tag.create(context: context, name: "B", type: .content)
        #expect(try context.fetchCount(.tags(.all)) == 2)
        try TagService.deleteAll(context: context)
        #expect(try context.fetchCount(.tags(.all)) == 0)
    }

    @Test
    func deleteAll_when_empty_is_noop() throws {
        #expect(try context.fetchCount(.tags(.all)) == 0)
        try TagService.deleteAll(context: context)
        #expect(try context.fetchCount(.tags(.all)) == 0)
    }
}
