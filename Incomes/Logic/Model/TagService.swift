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

    init(context: ModelContext) {
        self.repository = TagRepository(context: context)
    }

    func tags(predicate: Predicate<Tag>? = nil) throws -> [Tag] {
        try repository.fetchList(predicate: predicate)
    }

    func instantiate(_ name: String, for type: Tag.TagType) throws -> Tag {
        var tags = try repository.fetchList(predicate: Tag.predicate(name, for: type))
        guard let tag = tags.popLast() else {
            return .init(name, for: type)
        }
        try repository.deleteList(tags)
        return tag
    }

    func delete(tags: [Tag]) throws {
        try repository.deleteList(tags)
    }

    func deleteAll() throws {
        try delete(tags: tags())
    }
}
