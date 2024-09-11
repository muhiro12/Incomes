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
    private(set) var hasDuplicates = false

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Fetch

    func tag(_ descriptor: FetchDescriptor<Tag> = Tag.descriptor(.all)) throws -> Tag? {
        var descriptor = descriptor
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    // MARK: - Delete

    func deleteAll() throws {
        try delete(tags: context.fetch(.init()))
    }

    // MARK: - Duplicates

    func merge(tags: [Tag]) throws {
        guard let parent = tags.first else {
            return
        }
        let children = tags.filter {
            $0.id != parent.id
        }

        children.flatMap {
            $0.items ?? []
        }.forEach { item in
            var tags = item.tags ?? []
            tags.append(parent)
            item.modify(tags: tags)
        }

        try delete(tags: children)
    }

    func resolveAllDuplicates(in tags: [Tag]) throws {
        try tags.forEach { tag in
            try merge(
                tags: self.tags(
                    descriptor: Tag.descriptor(.isSameWith(tag))
                )
            )
        }
    }

    func findDuplicates(in tags: [Tag]) -> [Tag] {
        Dictionary(grouping: tags) { tag in
            tag.typeID + tag.name
        }
        .compactMap { _, values -> Tag? in
            guard values.count > 1 else {
                return nil
            }
            return values.first
        }
    }

    func updateHasDuplicates() throws {
        hasDuplicates = findDuplicates(
            in: try tags()
        ).isNotEmpty
    }
}

private extension TagService {
    func tags(descriptor: FetchDescriptor<Tag> = Tag.descriptor(.all)) throws -> [Tag] {
        try context.fetch(descriptor)
    }

    func delete(tags: [Tag]) throws {
        tags.forEach {
            $0.delete()
        }
    }
}
