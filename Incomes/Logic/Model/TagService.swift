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

    func create(_ name: String, for type: Tag.TagType) throws -> Tag {
        var tags = try repository.fetchList(predicate: Tag.predicate(name, for: type))
        guard let tag = tags.popLast() else {
            return .init(name, for: type)
        }
        try repository.deleteList(tags)
        return tag
    }

    func migrate() throws {
        guard let item = try itemRepository.fetch(),
              item.tags?.isEmpty != false else {
            return
        }
        let items = try itemRepository.fetchList().filter {
            $0.tags?.isEmpty != false
        }
        try items.forEach { item in
            item.set(tags: [
                try create(item.group, for: .category),
                try create(item.date.stringValueWithoutLocale(.yyyy), for: .year),
                try create(item.date.stringValueWithoutLocale(.yyyyMM), for: .yearMonth)
            ])
        }
        try itemRepository.updateList(items)
    }
}
