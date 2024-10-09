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

    // MARK: - Fetch

    @Test func tag() async throws {
        #expect(try service.tag() == nil)

        _ = try Tag.create(context: context, name: "nameA", type: .year)
        _ = try Tag.create(context: context, name: "nameB", type: .year)

        #expect(try context.fetchCount(.tags(.all)) == 2)

        #expect(try service.tag()?.name == "nameA")
        #expect(try service.tag()?.type == .year)
    }

    // MARK: - Delete

    @Test func deleteAll() async throws {
        #expect(try service.tag() == nil)

        _ = try Tag.create(context: context, name: "nameA", type: .year)
        _ = try Tag.create(context: context, name: "nameB", type: .year)

        #expect(try context.fetchCount(.tags(.all)) == 2)

        _ = try service.deleteAll()

        #expect(try context.fetchCount(.tags(.all)) == 0)
    }

    // MARK: - Duplicates - merge

    @Test func mergeWhenTagsAreIdentical() async throws {
        #expect(try service.tag() == nil)

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
            content: "contentA",
            income: .zero,
            outgo: .zero,
            category: "",
            repeatID: .init()
        )
        let item3 = try Item.create(
            context: context,
            date: .now,
            content: "contentA",
            income: .zero,
            outgo: .zero,
            category: "",
            repeatID: .init()
        )

        #expect(try context.fetchCount(.tags(.nameIs("contentA", type: .content))) == 1)

        let tag1 = item1.tags!.first { $0.type == .content }!
        let tag2 = item2.tags!.first { $0.type == .content }!
        let tag3 = item3.tags!.first { $0.type == .content }!

        #expect(tag1.id == tag2.id)
        #expect(tag1.id == tag3.id)
        #expect(tag2.id == tag3.id)

        try service.merge(tags: [tag1, tag2, tag3])

        #expect(try context.fetchCount(.tags(.nameIs("contentA", type: .content))) == 1)

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

        #expect(try context.fetchCount(.tags(.nameIs("contentA", type: .content))) == 1)
        #expect(try context.fetchCount(.tags(.nameIs("contentB", type: .content))) == 1)
        #expect(try context.fetchCount(.tags(.nameIs("contentC", type: .content))) == 1)

        let tag1 = item1.tags!.first { $0.type == .content }!
        let tag2 = item2.tags!.first { $0.type == .content }!
        let tag3 = item3.tags!.first { $0.type == .content }!

        #expect(tag1.id != tag2.id)
        #expect(tag1.id != tag3.id)
        #expect(tag2.id != tag3.id)

        try service.merge(tags: [tag1, tag2, tag3])

        #expect(try context.fetchCount(.tags(.nameIs("contentA", type: .content))) == 1)
        #expect(try context.fetchCount(.tags(.nameIs("contentB", type: .content))) == 0)
        #expect(try context.fetchCount(.tags(.nameIs("contentC", type: .content))) == 0)

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
            category: "",
            repeatID: .init()
        )
        let item2 = try Item.createIgnoringDuplicates(
            context: context,
            date: .now,
            content: "contentA",
            income: .zero,
            outgo: .zero,
            category: "",
            repeatID: .init()
        )
        let item3 = try Item.createIgnoringDuplicates(
            context: context,
            date: .now,
            content: "contentA",
            income: .zero,
            outgo: .zero,
            category: "",
            repeatID: .init()
        )

        #expect(try context.fetchCount(.tags(.nameIs("contentA", type: .content))) == 3)

        let tag1 = item1.tags!.first { $0.type == .content }!
        let tag2 = item2.tags!.first { $0.type == .content }!
        let tag3 = item3.tags!.first { $0.type == .content }!

        #expect(tag1.id != tag2.id)
        #expect(tag1.id != tag3.id)
        #expect(tag2.id != tag3.id)

        try service.merge(tags: [tag1, tag2, tag3])

        #expect(try context.fetchCount(.tags(.nameIs("contentA", type: .content))) == 1)

        #expect(tag1.items?.contains(item1) == true)
        #expect(tag1.items?.contains(item2) == true)
        #expect(tag1.items?.contains(item3) == true)

        #expect(item1.tags?.contains(tag1) == true)
        #expect(item2.tags?.contains(tag1) == true)
        #expect(item3.tags?.contains(tag1) == true)
    }

    // MARK: - Duplicates - resolveAllDuplicates

    @Test func resolveAllDuplicatesWithExpectedUsage() async throws {
        let tag1 = try Tag.createIgnoringDuplicates(context: context, name: "nameA", type: .year)
        _ = try Tag.createIgnoringDuplicates(context: context, name: "nameA", type: .year)
        _ = try Tag.createIgnoringDuplicates(context: context, name: "nameA", type: .year)
        let tag4 = try Tag.createIgnoringDuplicates(context: context, name: "nameB", type: .yearMonth)
        _ = try Tag.createIgnoringDuplicates(context: context, name: "nameB", type: .yearMonth)
        _ = try Tag.createIgnoringDuplicates(context: context, name: "nameB", type: .yearMonth)

        #expect(try context.fetchCount(.tags(.all)) == 6)

        try service.resolveAllDuplicates(in: [tag1, tag4])

        #expect(try context.fetchCount(.tags(.all)) == 2)
    }

    @Test func resolveAllDuplicatesWithUnexpectedUsage() async throws {
        let tag1 = try Tag.createIgnoringDuplicates(context: context, name: "nameA", type: .year)
        let tag2 = try Tag.createIgnoringDuplicates(context: context, name: "nameA", type: .year)
        _ = try Tag.createIgnoringDuplicates(context: context, name: "nameA", type: .year)
        _ = try Tag.createIgnoringDuplicates(context: context, name: "nameB", type: .yearMonth)
        _ = try Tag.createIgnoringDuplicates(context: context, name: "nameB", type: .yearMonth)
        _ = try Tag.createIgnoringDuplicates(context: context, name: "nameB", type: .yearMonth)

        #expect(try context.fetchCount(.tags(.all)) == 6)

        try service.resolveAllDuplicates(in: [tag1, tag2])

        #expect(try context.fetchCount(.tags(.all)) == 4)
    }

    // MARK: - Duplicates - findDuplicates

    @Test func findDuplicatesWithExpectedUsage() async throws {
        let tag1 = try Tag.createIgnoringDuplicates(context: context, name: "nameA", type: .year)
        let tag2 = try Tag.createIgnoringDuplicates(context: context, name: "nameA", type: .year)
        let tag3 = try Tag.createIgnoringDuplicates(context: context, name: "nameA", type: .year)
        let tag4 = try Tag.createIgnoringDuplicates(context: context, name: "nameA", type: .year)
        let tag5 = try Tag.createIgnoringDuplicates(context: context, name: "nameB", type: .yearMonth)
        let tag6 = try Tag.createIgnoringDuplicates(context: context, name: "nameB", type: .yearMonth)
        let tag7 = try Tag.createIgnoringDuplicates(context: context, name: "nameB", type: .yearMonth)
        let tag8 = try Tag.createIgnoringDuplicates(context: context, name: "nameB", type: .yearMonth)

        #expect(try context.fetchCount(.tags(.all)) == 8)

        let result = service.findDuplicates(in: [tag1, tag2, tag3, tag4, tag5, tag6, tag7, tag8])

        #expect(try context.fetchCount(.tags(.all)) == 8)

        #expect(result.count == 2)
        #expect(result.contains(tag1))
        #expect(result.contains(tag5))
    }

    @Test func findDuplicatesWithUnexpectedUsage() async throws {
        let tag1 = try Tag.createIgnoringDuplicates(context: context, name: "nameA", type: .year)
        let tag2 = try Tag.createIgnoringDuplicates(context: context, name: "nameA", type: .year)
        let tag3 = try Tag.createIgnoringDuplicates(context: context, name: "nameA", type: .yearMonth)
        let tag4 = try Tag.createIgnoringDuplicates(context: context, name: "nameA", type: .yearMonth)
        let tag5 = try Tag.createIgnoringDuplicates(context: context, name: "nameB", type: .year)
        let tag6 = try Tag.createIgnoringDuplicates(context: context, name: "nameB", type: .year)
        let tag7 = try Tag.createIgnoringDuplicates(context: context, name: "nameB", type: .yearMonth)
        let tag8 = try Tag.createIgnoringDuplicates(context: context, name: "nameB", type: .yearMonth)

        #expect(try context.fetchCount(.tags(.all)) == 8)

        let result = service.findDuplicates(in: [tag1, tag2, tag3, tag4, tag5, tag6, tag7, tag8])

        #expect(try context.fetchCount(.tags(.all)) == 8)

        #expect(result.count == 4)
        #expect(result.contains(tag1))
        #expect(result.contains(tag3))
        #expect(result.contains(tag5))
        #expect(result.contains(tag7))
    }

    // MARK: - Duplicates - updateHasDuplicates

    @Test func updateHasDuplicates() async throws {
        #expect(service.hasDuplicates == false)

        try service.updateHasDuplicates()
        #expect(service.hasDuplicates == false)

        let tag1 = try Tag.createIgnoringDuplicates(context: context, name: "name1", type: .year)

        try service.updateHasDuplicates()
        #expect(service.hasDuplicates == false)

        let tag2 = try Tag.createIgnoringDuplicates(context: context, name: "name1", type: .year)

        try service.updateHasDuplicates()
        #expect(service.hasDuplicates == true)

        let tag3 = try Tag.createIgnoringDuplicates(context: context, name: "name1", type: .year)

        try service.updateHasDuplicates()
        #expect(service.hasDuplicates == true)

        try service.merge(tags: [tag1, tag2, tag3])

        try service.updateHasDuplicates()
        #expect(service.hasDuplicates == false)
    }
}
