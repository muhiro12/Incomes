//
//  SwiftDataController.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/11.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

struct SwiftDataController {
    private let migrator: SwiftDataMigrator
    private let tagService: TagService

    init(context: ModelContext) {
        self.migrator = SwiftDataMigrator(context: context)
        self.tagService = TagService(context: context)
    }

    func modify() {
        do {
            if try tagService.tags().isEmpty {
                try migrator.migrateToV2()
            } else {
                try deleteDuplicateTags()
            }
        } catch {
            assertionFailure()
        }
    }

    func deleteDuplicateTags() throws {
        let allTags = try tagService.tags()

        var unique = [Tag]()
        var duplicate = [Tag]()

        allTags.forEach { tag in
            if unique.contains(tag) {
                tag.items?.forEach { item in
                    var tags = item.tags ?? []
                    tags.removeAll { $0 == tag }
                    tags.append(tag)
                    item.set(tags: tags)
                }
                duplicate.append(tag)
            } else {
                unique.append(tag)
            }
        }

        try tagService.delete(tags: duplicate)
    }
}
