//
//  Tag.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/09.
//

import Foundation
import SwiftData

/// A classification tag that groups related items (e.g., year, month, category).
@Model
public final class Tag {
    /// Stored tag name value.
    public private(set) var name = ""
    /// Stored raw tag type identifier.
    public private(set) var typeID = ""

    /// Items that currently reference this tag.
    /// SwiftData represents to-many relationships as optionals before faulting.
    public private(set) var items: [Item]? // swiftlint:disable:this discouraged_optional_collection

    private init() {
        // no-op
    }

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

    /// Service-only helper that updates the stored tag name in place.
    func rename(storedName: String) {
        name = storedName
    }
}

public extension Tag {
    /// The strongly-typed tag kind, derived from `typeID`.
    var type: TagType? {
        TagType(rawValue: typeID)
    }

    /// A localized or user-friendly name for the tag.
    var displayName: String {
        TagTextSupport.displayName(
            name: name,
            type: type
        )
    }

    /// Sum of `income` across related items.
    var income: Decimal {
        (items ?? []).reduce(.zero) { partial, item in
            partial + item.income
        }
    }

    /// Sum of `outgo` across related items.
    var outgo: Decimal {
        (items ?? []).reduce(.zero) { partial, item in
            partial + item.outgo
        }
    }

    /// Convenience: `income - outgo`.
    var netIncome: Decimal {
        income - outgo
    }

    /// True when any related item has a negative running balance (deficit).
    /// Used for quick visual warnings in summary lists.
    var hasDeficit: Bool {
        (items ?? []).contains { item in
            item.balance < .zero
        }
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

public extension Tag {
    /// Testing helper: creates a tag without checking duplicates.
    static func createIgnoringDuplicates(context: ModelContext, name: String, type: TagType) -> Tag {
        let tag = Tag()
        context.insert(tag)
        tag.name = name
        tag.typeID = type.rawValue
        return tag
    }
}
