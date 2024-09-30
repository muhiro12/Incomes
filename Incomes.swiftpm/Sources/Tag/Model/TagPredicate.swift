//
//  TagPredicate.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/10.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

enum TagPredicate {
    case all
    case none
    case idIs(Tag.ID)
    case isSameWith(Tag)
    case nameAndType(name: String, type: Tag.TagType)
    case typeIs(Tag.TagType)
    case yearIs(String)
    case dateIsSameMonthAs(Date)
    case contentIsIn([String])
    case nameContains(name: String, type: Tag.TagType)

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
        case .nameAndType(name: let name, type: let type):
            let id = type.rawValue
            return #Predicate {
                $0.name == name && $0.typeID == id
            }
        case .typeIs(let type):
            let id = type.rawValue
            return #Predicate {
                $0.typeID == id
            }
        case .yearIs(let year):
            let id = Tag.TagType.yearMonth.rawValue
            return #Predicate {
                $0.name.starts(with: year) && $0.typeID == id
            }
        case .dateIsSameMonthAs(let date):
            let name = date.stringValueWithoutLocale(.yyyyMM)
            let id = Tag.TagType.yearMonth.rawValue
            return #Predicate {
                $0.name == name && $0.typeID == id
            }
        case .contentIsIn(let contents):
            let id = Tag.TagType.content.rawValue
            return #Predicate {
                contents.contains($0.name) && $0.typeID == id
            }
        case .nameContains(let name, let type):
            let typeID = type.rawValue
            let hiragana = name.applyingTransform(.hiraganaToKatakana, reverse: true).orEmpty
            let katakana = name.applyingTransform(.hiraganaToKatakana, reverse: false).orEmpty
            return #Predicate {
                $0.typeID == typeID
                    && $0.name.localizedStandardContains(name)
                    || $0.name.localizedStandardContains(hiragana)
                    || $0.name.localizedStandardContains(katakana)
            }
        }
    }
}

extension FetchDescriptor where T == Tag {
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
