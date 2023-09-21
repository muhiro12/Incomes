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
        var tags = try repository.fetchList(predicate: Tag.predicate(name, for: type))
        guard let tag = tags.popLast() else {
            let tag = Tag()
            context.insert(tag)
            tag.set(name: name, typeID: type.rawValue)
            return tag
        }
        try repository.deleteList(tags)
        return tag
    }
}
