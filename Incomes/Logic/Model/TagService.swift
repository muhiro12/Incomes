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

    func tag(predicate: Predicate<Tag>? = nil) throws -> Tag? {
        try repository.fetch(predicate: predicate)
    }

    func tags(predicate: Predicate<Tag>? = nil) throws -> [Tag] {
        try repository.fetchList(predicate: predicate)
    }

    func delete(tags: [Tag]) throws {
        try repository.deleteList(tags)
    }

    func deleteAll() throws {
        try delete(tags: tags())
    }
}
