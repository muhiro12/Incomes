//
//  Tag.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/09.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

/// A classification tag that groups related items (e.g., year, month, category).
@Model
public final class Tag {
    public private(set) var name = String.empty
    public private(set) var typeID = String.empty

    public private(set) var items: [Item]?

    private init() {}

    /// Creates or returns an existing tag with the given `name` and `type`.
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
    /// The strongly-typed tag kind, derived from `typeID`.
    public var type: TagType? {
        TagType(rawValue: typeID)
    }

    /// A localized or user-friendly name for the tag.
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

    /// Sum of `income` across related items.
    public var income: Decimal {
        items.orEmpty.reduce(.zero) { $0 + $1.income }
    }

    /// Sum of `outgo` across related items.
    public var outgo: Decimal {
        items.orEmpty.reduce(.zero) { $0 + $1.outgo }
    }

    /// Convenience: `income - outgo`.
    public var netIncome: Decimal {
        income - outgo
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
    /// Testing helper: creates a tag without checking duplicates.
    public static func createIgnoringDuplicates(context: ModelContext, name: String, type: TagType) throws -> Tag {
        let tag = Tag()
        context.insert(tag)
        tag.name = name
        tag.typeID = type.rawValue
        return tag
    }
}
