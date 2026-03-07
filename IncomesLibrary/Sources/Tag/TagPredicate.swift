//
//  TagPredicate.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/10.
//

import Foundation
import SwiftData

/// Discrete predicate presets for fetching tags.
public enum TagPredicate {
    /// Matches every tag.
    case all
    /// Matches no tags.
    case none // swiftlint:disable:this discouraged_none_name
    /// Matches a tag with the specified persistent identifier.
    case idIs(Tag.ID)
    /// Matches tags with the same name and type as the given tag.
    case isSameWith(Tag)
    /// Matches tags of the specified type.
    case typeIs(TagType)
    /// Matches a tag with an exact name and type.
    case nameIs(String, type: TagType)
    /// Matches tags whose name contains the search text for the specified type.
    case nameContains(String, type: TagType)
    /// Matches tags whose name starts with the prefix for the specified type.
    case nameStartsWith(String, type: TagType)

    var value: Predicate<Tag> {
        switch self {
        case .all:
            return .true
        case .none:
            return .false
        case .idIs(let id):
            return #Predicate { tag in
                tag.persistentModelID == id
            }
        case .isSameWith(let tag):
            let name = tag.name
            let typeID = tag.typeID
            return #Predicate { tag in
                tag.name == name && tag.typeID == typeID
            }
        case .typeIs(let type):
            let id = type.rawValue
            return #Predicate { tag in
                tag.typeID == id
            }
        case let .nameIs(name, type):
            let id = type.rawValue
            return #Predicate { tag in
                tag.name == name && tag.typeID == id
            }
        case let .nameContains(name, type):
            let typeID = type.rawValue
            let hiragana = name.applyingTransform(.hiraganaToKatakana, reverse: true).orEmpty
            let katakana = name.applyingTransform(.hiraganaToKatakana, reverse: false).orEmpty
            return #Predicate { tag in
                tag.typeID == typeID
                    && (
                        tag.name.localizedStandardContains(name)
                            || tag.name.localizedStandardContains(hiragana)
                            || tag.name.localizedStandardContains(katakana)
                    )
            }
        case let .nameStartsWith(name, type):
            let id = type.rawValue
            return #Predicate { tag in
                tag.name.starts(with: name) && tag.typeID == id
            }
        }
    }
}

public extension FetchDescriptor where T == Tag {
    /// Convenience factory for a `FetchDescriptor<Tag>` using a `TagPredicate`.
    /// - Parameters:
    ///   - predicate: A preset predicate.
    ///   - order: Sort order (default: forward).
    static func tags(_ predicate: TagPredicate, order: SortOrder = .forward) -> FetchDescriptor {
        .init(
            predicate: predicate.value,
            sortBy: [
                .init(\.name, order: order),
                .init(\.typeID, order: order),
                .init(\.persistentModelID, order: order)
            ]
        )
    }
}
