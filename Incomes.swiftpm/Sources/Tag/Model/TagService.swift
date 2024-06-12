//
//  TagService.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/09.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

@Observable
final class TagService {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Fetch

    func tag(predicate: Predicate<Tag>? = nil) throws -> Tag? {
        var descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: Tag.sortDescriptors()
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    func tags(predicate: Predicate<Tag>? = nil) throws -> [Tag] {
        try context.fetch(.init(predicate: predicate, sortBy: Tag.sortDescriptors()))
    }

    // MARK: - Create

    func create(name: String, type: Tag.TagType) throws -> Tag {
        try .create(context: context, name: name, type: type)
    }

    func createTags(date: Date, content: String, group: String) throws -> [Tag] {
        [
            try create(
                name: Calendar.utc.startOfYear(for: date).stringValueWithoutLocale(.yyyy),
                type: .year
            ),
            try create(
                name: Calendar.utc.startOfMonth(for: date).stringValueWithoutLocale(.yyyyMM),
                type: .yearMonth
            ),
            try create(
                name: content,
                type: .content
            ),
            try create(
                name: group,
                type: .category
            )
        ]
    }

    // MARK: - Delete

    func delete(tags: [Tag]) throws {
        try tags.forEach {
            try $0.delete()
        }
    }

    func deleteAll() throws {
        try delete(tags: tags())
    }

    // MARK: - Merge

    func merge(tags: [Tag]) throws {
        guard let parent = tags.first else {
            return
        }
        let children = Array(tags.dropFirst())

        children.flatMap {
            $0.items ?? []
        }.forEach { item in
            var tags = item.tags ?? []
            tags.append(parent)
            item.modify(tags: tags)
        }

        try delete(tags: children)
    }
}
