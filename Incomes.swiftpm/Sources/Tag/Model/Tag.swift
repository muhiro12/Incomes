//
//  Tag.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/09.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Tag {
    enum TagType: String {
        case year = "aae8af65"
        case yearMonth = "27c9be4b"
        case content = "e2d390d9"
        case category = "a7a130f4"
    }

    private(set) var name = String.empty
    private(set) var typeID = String.empty

    private(set) var items: [Item]?

    private init() {}

    static func create(context: ModelContext, name: String, type: Tag.TagType) throws -> Tag {
        let tag = try context.fetchFirst(.tags(.nameIs(name, type: type))) ?? .init()
        context.insert(tag)
        tag.name = name
        tag.typeID = type.rawValue
        return tag
    }
}

extension Tag {
    var type: TagType? {
        TagType(rawValue: typeID)
    }

    var displayName: String {
        switch type {
        case .year:
            name.dateValueWithoutLocale(.yyyy)?.stringValue(.yyyy) ?? name
        case .yearMonth:
            name.dateValueWithoutLocale(.yyyyMM)?.stringValue(.yyyyMMM) ?? name
        case .content:
            name
        case .category:
            name.isNotEmpty ? name : "Others"
        case .none:
            name
        }
    }
}

extension Tag: Identifiable {}

// MARK: - Test

extension Tag {
    static func createIgnoringDuplicates(context: ModelContext, name: String, type: Tag.TagType) throws -> Tag {
        let tag = Tag()
        context.insert(tag)
        tag.name = name
        tag.typeID = type.rawValue
        return tag
    }
}
