//
//  TagService.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/09.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

struct TagService {
    private let repository: any Repository<Tag>
    private let itemRepository: any Repository<Item>

    init(context: ModelContext) {
        self.repository = TagRepository(context: context)
        self.itemRepository = ItemRepository(context: context)
    }

    func instantiate(_ name: String, for type: Tag.TagType) throws -> Tag {
        var tags = try repository.fetchList(predicate: Tag.predicate(name, for: type))
        guard let tag = tags.popLast() else {
            return .init(name, for: type)
        }
        try repository.deleteList(tags)
        return tag
    }

    func deleteAll() throws {
        let tags = try repository.fetchList()
        try repository.deleteList(tags)
    }

    func modify() {
        do {
            if let item = try itemRepository.fetch(),
               item.tags?.isEmpty != false {
                try migrateToV2()
            } else {
                try deleteDuplicates()
            }
        } catch {
            assertionFailure()
        }
    }

    func migrateToV2() throws {
        let items = try itemRepository.fetchList().filter {
            $0.tags?.isEmpty != false
        }
        try items.forEach { item in
            item.set(tags: [
                try instantiate(item.group, for: .category),
                try instantiate(item.date.stringValueWithoutLocale(.yyyy), for: .year),
                try instantiate(item.date.stringValueWithoutLocale(.yyyyMM), for: .yearMonth)
            ])
        }
        try itemRepository.updateList(items)
    }

    func deleteDuplicates() throws {
        let allTags = try repository.fetchList()

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

        try repository.deleteList(duplicate)
    }
}
