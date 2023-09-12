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
    private let repository: any Repository<Tag>

    init(context: ModelContext) {
        self.repository = TagRepository(context: context)
    }

    func callAsFunction(_ name: String, for type: Tag.TagType) throws -> Tag {
        var tags = try repository.fetchList(predicate: Tag.predicate(name, for: type))
        guard let tag = tags.popLast() else {
            return .init(name: name, typeID: type.rawValue)
        }
        try repository.deleteList(tags)
        return tag
    }
}
