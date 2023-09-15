//
//  SwiftDataMigrator.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/13.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

struct SwiftDataMigrator {
    let context: ModelContext

    func isBeforeV2() throws -> Bool {
        try context.fetchCount(FetchDescriptor<Tag>()) <= 0
    }

    func migrateToV2() throws {
        let items = try context.fetch(FetchDescriptor<Item>()).filter {
            $0.tags?.isEmpty != false
        }

        let tag = { (name: String, type: Tag.TagType) in
            let typeID = type.rawValue
            var tags = try context.fetch(FetchDescriptor<Tag>(predicate: #Predicate {
                $0.name == name && $0.typeID == typeID
            }))

            if let tag = tags.popLast() {
                tags.forEach(context.delete)
                return tag
            }

            let tag = Tag()
            tag.set(name: name, typeID: type.rawValue)
            return tag
        }

        try items.forEach { item in
            item.set(tags: [
                try tag(Calendar.utc.startOfYear(for: item.date).stringValueWithoutLocale(.yyyy),
                        .year),
                try tag(Calendar.utc.startOfMonth(for: item.date).stringValueWithoutLocale(.yyyyMM),
                        .yearMonth),
                try tag(item.content,
                        .content),
                try tag(item.group,
                        .category)
            ])
        }

        try context.save()
    }
}
