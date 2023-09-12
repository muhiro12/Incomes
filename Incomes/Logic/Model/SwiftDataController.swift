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
    private let itemService: ItemService
    private let tagService: TagService

    init(context: ModelContext) {
        self.itemService = ItemService(context: context)
        self.tagService = TagService(context: context)
    }

    func modify() {
        do {
            if let item = try itemService.item(),
               item.tags?.isEmpty != false {
                try migrateToV2()
            } else {
                try deleteDuplicateTags()
            }
        } catch {
            assertionFailure()
        }
    }

    func migrateToV2() throws {
        let items = try itemService.items().filter {
            $0.tags?.isEmpty != false
        }
        try items.forEach { item in
            item.set(tags: [
                try tagService.instantiate(item.group, for: .category),
                try tagService.instantiate(item.date.stringValueWithoutLocale(.yyyy), for: .year),
                try tagService.instantiate(item.date.stringValueWithoutLocale(.yyyyMM), for: .yearMonth)
            ])
        }
        try itemService.update(items: items)
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
