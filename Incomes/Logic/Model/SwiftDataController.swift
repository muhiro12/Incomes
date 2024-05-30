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
    private let itemService: ItemService
    private let tagService: TagService

    init(context: ModelContext) {
        self.migrator = .init(context: context)
        self.itemService = .init(context: context)
        self.tagService = .init(context: context)
    }

    func modify() {
        do {
            if try migrator.isBeforeV2() {
                try migrator.migrateToV2()
            } else {
                try deleteInvalidTags()
            }
        } catch {
            assertionFailure()
        }
    }

    func deleteInvalidTags() throws {
        let allTags = try tagService.tags()

        var valids = [Tag]()
        var invalids = [Tag]()

        allTags.forEach { tag in
            if !valids.contains(tag),
               tag.items?.isNotEmpty == true {
                valids.append(tag)
                return
            }
            tag.items?.forEach { item in
                var tags = item.tags ?? []
                tags.removeAll { $0 == tag }
                tags.append(tag)
                itemService.update(item: item, tags: tags)
            }
            invalids.append(tag)
        }

        try tagService.delete(tags: invalids)
    }
}
