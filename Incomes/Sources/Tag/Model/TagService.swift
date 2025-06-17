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

        try children
            .compactMap(TagEntity.init)
            .forEach {
                try DeleteTagIntent.perform((context: context, tag: $0))
            }
    }

    func resolveAllDuplicates(in tags: [Tag]) throws {
        try tags.forEach { tag in
            let duplicates = try context.fetch(
                .tags(.isSameWith(tag))
            )
            try merge(tags: duplicates)
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
        let allTags = try context.fetch(.tags(.all))
        hasDuplicates = findDuplicates(in: allTags).isNotEmpty
    }
}
