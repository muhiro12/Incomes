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

    // MARK: - Delete

    func deleteAll() throws {
        try delete(tags: context.fetch(.init()))
    }

    // MARK: - Merge

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
}

private extension TagService {
    func delete(tags: [Tag]) throws {
        try tags.forEach {
            try $0.delete()
        }
    }
}
