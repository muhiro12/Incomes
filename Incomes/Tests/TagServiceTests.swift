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

    @Test func tag() async throws {
        #expect(try service.tag() == nil)

        _ = try Tag.create(context: context, name: "name", type: .year)

        #expect(try service.tag()?.name == "name")
        #expect(try service.tag()?.type == .year)
    }

    @Test func deleteAll() async throws {
        #expect(try service.tag() == nil)

        _ = try Tag.create(context: context, name: "name", type: .year)

        #expect(try service.tag() != nil)

        _ = try service.deleteAll()

        #expect(try service.tag() == nil)
    }

    @Test func mergeWhenTagsAreDifferent() async throws {
        #expect(try service.tag() == nil)

        let tag1 = try Tag.create(context: context, name: "nameA", type: .year)
        let tag2 = try Tag.create(context: context, name: "nameB", type: .year)

        #expect(try service.tag(predicate: Tag.predicate(name: "nameA", type: .year)) != nil)
        #expect(try service.tag(predicate: Tag.predicate(name: "nameB", type: .year)) != nil)

        try service.merge(tags: [tag1, tag2])

        #expect(try service.tag(predicate: Tag.predicate(name: "nameA", type: .year)) != nil)
        #expect(try service.tag(predicate: Tag.predicate(name: "nameB", type: .year)) == nil)
    }

    @Test func mergeWhenTagsAreDuplicated() async throws {
        #expect(try service.tag() == nil)

        let tag1 = try Tag.createIgnoringDuplicates(context: context, name: "nameA", type: .year)
        let tag2 = try Tag.createIgnoringDuplicates(context: context, name: "nameA", type: .year)

        #expect(try service.tag(predicate: Tag.predicate(name: "nameA", type: .year)) != nil)
        #expect(try context.fetchCount(.init(sortBy: Tag.sortDescriptors())) == 2)

        try service.merge(tags: [tag1, tag2])

        #expect(try service.tag(predicate: Tag.predicate(name: "nameA", type: .year)) != nil)
        #expect(try context.fetchCount(.init(sortBy: Tag.sortDescriptors())) == 1)
    }

    @Test func mergeWhenTagsAreIdentical() async throws {
        #expect(try service.tag() == nil)

        let tag1 = try Tag.create(context: context, name: "nameA", type: .year)
        let tag2 = try Tag.create(context: context, name: "nameA", type: .year)

        #expect(try service.tag(predicate: Tag.predicate(name: "nameA", type: .year)) != nil)
        #expect(try context.fetchCount(.init(sortBy: Tag.sortDescriptors())) == 1)

        try service.merge(tags: [tag1, tag2])

        #expect(try service.tag(predicate: Tag.predicate(name: "nameA", type: .year)) != nil)
        #expect(try context.fetchCount(.init(sortBy: Tag.sortDescriptors())) == 1)
    }
}
