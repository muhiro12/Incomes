//
//  TagRepository.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/09.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

struct TagRepository: Repository {
    typealias Entity = Tag

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetch(predicate: Predicate<Tag>?) throws -> Tag? {
        var descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: Tag.sortDescriptors()
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    func fetchList(predicate: Predicate<Tag>?) throws -> [Tag] {
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: Tag.sortDescriptors()
        )
        return try context.fetch(descriptor)
    }

    func add(_ entity: Tag) throws {
        context.insert(entity)
        try context.save()
    }

    func addList(_ list: [Tag]) throws {
        list.forEach(context.insert)
        try context.save()
    }

    func update(_ entity: Tag) throws {
        try context.save()
    }

    func updateList(_ list: [Tag]) throws {
        try context.save()
    }

    func delete(_ entity: Tag) throws {
        context.delete(entity)
        try context.save()
    }

    func deleteList(_ list: [Tag]) throws {
        list.forEach(context.delete)
        try context.save()
    }
}
