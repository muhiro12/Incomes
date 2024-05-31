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

    private(set) var items: [Item]? // swiftlint:disable:this discouraged_optional_collection

    private init() {}

    static func create(context: ModelContext, name: String, type: Tag.TagType) throws -> Tag {
        var tags = try context.fetch(
            .init(predicate: Self.predicate(name: name, type: type), sortBy: Self.sortDescriptors())
        )
        guard let tag = tags.popLast() else {
            let tag = Tag()
            context.insert(tag)
            tag.name = name
            tag.typeID = type.rawValue
            return tag
        }
        tags.forEach(context.delete)
        try context.save()
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
            return name.dateValueWithoutLocale(.yyyy)?.stringValue(.yyyy) ?? name

        case .yearMonth:
            return name.dateValueWithoutLocale(.yyyyMM)?.stringValue(.yyyyMMM) ?? name

        default:
            return name
        }
    }
}

extension Tag: Equatable {
    static func == (lhs: Tag, rhs: Tag) -> Bool {
        lhs.name == rhs.name && lhs.typeID == rhs.typeID
    }
}

extension Tag: Identifiable {}
