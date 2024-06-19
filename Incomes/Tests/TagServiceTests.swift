//
//  TagServiceTests.swift
//
//
//  Created by Hiromu Nakano on 2024/06/17.
//

@testable import IncomesPlaygrounds
import SwiftData
import Testing

struct TagServiceTests {
    let context: ModelContext
    let service: TagService

    init() {
        self.context = testContext
        self.service = .init(context: context)
    }

    // MARK: - tag

    @Test func tag() async throws {
        #expect(try service.tag() == nil)

        _ = try Tag.create(context: context, name: "name", type: .year)

        #expect(try service.tag()?.name == "name")
        #expect(try service.tag()?.type == .year)
    }

    // MARK: - deleteAll

    @Test func deleteAll() async throws {
        #expect(try service.tag() == nil)

        _ = try Tag.create(context: context, name: "name", type: .year)

        #expect(try service.tag() != nil)

        _ = try service.deleteAll()

        #expect(try service.tag() == nil)
    }

    // MARK: - Duplicates

    @Test func mergeWhenTagsAreIdentical() async throws {
        #expect(try service.tag() == nil)

        let item1 = try Item.create(
            context: context,
            date: .now,
            content: "contentA",
            income: .zero,
            outgo: .zero,
            group: "",
            repeatID: .init()
        )
        let item2 = try Item.create(
            context: context,
            date: .now,
            content: "contentA",
            income: .zero,
            outgo: .zero,
            group: "",
            repeatID: .init()
        )
        let item3 = try Item.create(
            context: context,
            date: .now,
            content: "contentA",
            income: .zero,
            outgo: .zero,
            group: "",
            repeatID: .init()
        )

        #expect(try context.fetchCount(.init(predicate: Tag.predicate(contents: ["contentA"]))) == 1)

        let tag1 = item1.tags!.first { $0.type == .content }!
        let tag2 = item2.tags!.first { $0.type == .content }!
        let tag3 = item3.tags!.first { $0.type == .content }!

        #expect(tag1.id == tag2.id)
        #expect(tag1.id == tag3.id)
        #expect(tag2.id == tag3.id)

        try service.merge(tags: [tag1, tag2, tag3])

        #expect(try context.fetchCount(.init(predicate: Tag.predicate(contents: ["contentA"]))) == 1)

        #expect(tag1.items?.contains(item1) == true)
        #expect(tag1.items?.contains(item2) == true)
        #expect(tag1.items?.contains(item3) == true)

        #expect(item1.tags?.contains(tag1) == true)
        #expect(item1.tags?.contains(tag2) == true)
        #expect(item1.tags?.contains(tag3) == true)
    }

    @Test func mergeWhenTagsAreDifferent() async throws {
        #expect(try service.tag() == nil)

        let item1 = try Item.create(
            context: context,
            date: .now,
            content: "contentA",
            income: .zero,
            outgo: .zero,
            group: "",
            repeatID: .init()
        )
        let item2 = try Item.create(
            context: context,
            date: .now,
            content: "contentB",
            income: .zero,
            outgo: .zero,
            group: "",
            repeatID: .init()
        )
        let item3 = try Item.create(
            context: context,
            date: .now,
            content: "contentC",
            income: .zero,
            outgo: .zero,
            group: "",
            repeatID: .init()
        )

        #expect(try context.fetchCount(.init(predicate: Tag.predicate(contents: ["contentA"]))) == 1)
        #expect(try context.fetchCount(.init(predicate: Tag.predicate(contents: ["contentB"]))) == 1)
        #expect(try context.fetchCount(.init(predicate: Tag.predicate(contents: ["contentC"]))) == 1)

        let tag1 = item1.tags!.first { $0.type == .content }!
        let tag2 = item2.tags!.first { $0.type == .content }!
        let tag3 = item3.tags!.first { $0.type == .content }!

        #expect(tag1.id != tag2.id)
        #expect(tag1.id != tag3.id)
        #expect(tag2.id != tag3.id)

        try service.merge(tags: [tag1, tag2, tag3])

        #expect(try context.fetchCount(.init(predicate: Tag.predicate(contents: ["contentA"]))) == 1)
        #expect(try context.fetchCount(.init(predicate: Tag.predicate(contents: ["contentB"]))) == 0)
        #expect(try context.fetchCount(.init(predicate: Tag.predicate(contents: ["contentC"]))) == 0)

        #expect(tag1.items?.contains(item1) == true)
        #expect(tag1.items?.contains(item2) == true)
        #expect(tag1.items?.contains(item3) == true)

        #expect(item1.tags?.contains(tag1) == true)
        #expect(item2.tags?.contains(tag1) == true)
        #expect(item3.tags?.contains(tag1) == true)
    }

    @Test func mergeWhenTagsAreDuplicated() async throws {
        #expect(try service.tag() == nil)

        let item1 = try Item.createIgnoringDuplicates(
            context: context,
            date: .now,
            content: "contentA",
            income: .zero,
            outgo: .zero,
            group: "",
            repeatID: .init()
        )
        let item2 = try Item.createIgnoringDuplicates(
            context: context,
            date: .now,
            content: "contentA",
            income: .zero,
            outgo: .zero,
            group: "",
            repeatID: .init()
        )
        let item3 = try Item.createIgnoringDuplicates(
            context: context,
            date: .now,
            content: "contentA",
            income: .zero,
            outgo: .zero,
            group: "",
            repeatID: .init()
        )

        #expect(try context.fetchCount(.init(predicate: Tag.predicate(contents: ["contentA"]))) == 3)

        let tag1 = item1.tags!.first { $0.type == .content }!
        let tag2 = item2.tags!.first { $0.type == .content }!
        let tag3 = item3.tags!.first { $0.type == .content }!

        #expect(tag1.id != tag2.id)
        #expect(tag1.id != tag3.id)
        #expect(tag2.id != tag3.id)

        try service.merge(tags: [tag1, tag2, tag3])

        #expect(try context.fetchCount(.init(predicate: Tag.predicate(contents: ["contentA"]))) == 1)

        #expect(tag1.items?.contains(item1) == true)
        #expect(tag1.items?.contains(item2) == true)
        #expect(tag1.items?.contains(item3) == true)

        #expect(item1.tags?.contains(tag1) == true)
        #expect(item2.tags?.contains(tag1) == true)
        #expect(item3.tags?.contains(tag1) == true)
    }
}
