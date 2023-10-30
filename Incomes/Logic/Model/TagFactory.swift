//
//  TagFactory.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/13.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

struct TagFactory {
    let context: ModelContext

    func callAsFunction(_ name: String, for type: Tag.TagType) throws -> Tag {
        let repository = TagRepository(context: context)
        var tags = try repository.fetchList(predicate: Tag.predicate(name: name, type: type))
        guard let tag = tags.popLast() else {
            let tag = Tag()
            context.insert(tag)
            tag.set(name: name, typeID: type.rawValue)
            return tag
        }
        try repository.deleteList(tags)
        return tag
    }

    func tags(date: Date, content: String, group: String) throws -> [Tag] {
        [try self(Calendar.utc.startOfYear(for: date).stringValueWithoutLocale(.yyyy), for: .year),
         try self(Calendar.utc.startOfMonth(for: date).stringValueWithoutLocale(.yyyyMM), for: .yearMonth),
         try self(content, for: .content),
         try self(group, for: .category)]
    }
}
