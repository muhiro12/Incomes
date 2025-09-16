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
public final class Tag {
    public private(set) var name = String.empty
    public private(set) var typeID = String.empty

    public private(set) var items: [Item]?

    private init() {}

    public static func create(context: ModelContext, name: String, type: TagType) throws -> Tag {
        let tag = try context.fetchFirst(
            .tags(.nameIs(name, type: type))
        ) ?? .init()
        context.insert(tag)
        tag.name = name
        tag.typeID = type.rawValue
        return tag
    }
}

extension Tag {
    public var type: TagType? {
        TagType(rawValue: typeID)
    }

    public var displayName: String {
        switch type {
        case .year:
            name.dateValueWithoutLocale(.yyyy)?.stringValue(.yyyy) ?? name
        case .yearMonth:
            name.dateValueWithoutLocale(.yyyyMM)?.stringValue(.yyyyMMM) ?? name
        case .content:
            name
        case .category:
            name.isNotEmpty ? name : "Others"
        case .debug:
            name
        case .none:
            name
        }
    }

    public var income: Decimal {
        items.orEmpty.reduce(.zero) { $0 + $1.income }
    }

    public var outgo: Decimal {
        items.orEmpty.reduce(.zero) { $0 + $1.outgo }
    }
}

extension Tag: Identifiable {}

// MARK: - Hashable

extension Tag: Hashable {
    public static func == (lhs: Tag, rhs: Tag) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Test

extension Tag {
    public static func createIgnoringDuplicates(context: ModelContext, name: String, type: TagType) throws -> Tag {
        let tag = Tag()
        context.insert(tag)
        tag.name = name
        tag.typeID = type.rawValue
        return tag
    }
}
