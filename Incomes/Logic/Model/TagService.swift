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
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func tag(predicate: Predicate<Tag>? = nil) throws -> Tag? {
        var descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: Tag.sortDescriptors()
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    func tags(predicate: Predicate<Tag>? = nil) throws -> [Tag] {
        try context.fetch(.init(predicate: predicate, sortBy: Tag.sortDescriptors()))
    }

    func delete(tags: [Tag]) throws {
        try tags.forEach {
            try $0.delete()
        }
    }

    func deleteAll() throws {
        try delete(tags: tags())
    }
}
