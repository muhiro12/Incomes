//
//  TagPredicate.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/10.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

/// Discrete predicate presets for fetching tags.
public enum TagPredicate {
    case all
    case none
    case idIs(Tag.ID)
    case isSameWith(Tag)
    case typeIs(TagType)
    case nameIs(String, type: TagType)
    case nameContains(String, type: TagType)
    case nameStartsWith(String, type: TagType)

    var value: Predicate<Tag> {
        switch self {
        case .all:
            return .true
        case .none:
            return .false
        case .idIs(let id):
            return #Predicate {
                $0.persistentModelID == id
            }
        case .isSameWith(let tag):
            let name = tag.name
            let typeID = tag.typeID
            return #Predicate {
                $0.name == name && $0.typeID == typeID
            }
        case .typeIs(let type):
            let id = type.rawValue
            return #Predicate {
                $0.typeID == id
            }
        case .nameIs(let name, let type):
            let id = type.rawValue
            return #Predicate {
                $0.name == name && $0.typeID == id
            }
        case .nameContains(let name, let type):
            let typeID = type.rawValue
            let hiragana = name.applyingTransform(.hiraganaToKatakana, reverse: true).orEmpty
            let katakana = name.applyingTransform(.hiraganaToKatakana, reverse: false).orEmpty
            return #Predicate {
                $0.typeID == typeID
                    && (
                        $0.name.localizedStandardContains(name)
                            || $0.name.localizedStandardContains(hiragana)
                            || $0.name.localizedStandardContains(katakana)
                    )
            }
        case .nameStartsWith(let name, let type):
            let id = type.rawValue
            return #Predicate {
                $0.name.starts(with: name) && $0.typeID == id
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
