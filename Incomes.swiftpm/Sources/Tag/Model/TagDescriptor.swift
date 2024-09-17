//
//  TagDescriptor.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/10.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

extension Tag {
    enum Predicate {
        case all
        case none
        case idIs(ID)
        case isSameWith(Tag)
        case nameAndType(name: String, type: TagType)
        case typeIs(TagType)
        case yearIs(String)
        case dateIsSameMonthAs(Date)
        case contentIsIn([String])

        var value: Foundation.Predicate<Tag> {
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
                let id = TagType.yearMonth.rawValue
                return #Predicate {
                    $0.name.starts(with: year) && $0.typeID == id
                }
            case .dateIsSameMonthAs(let date):
                let name = date.stringValueWithoutLocale(.yyyyMM)
                let id = TagType.yearMonth.rawValue
                return #Predicate {
                    $0.name == name && $0.typeID == id
                }
            case .contentIsIn(let contents):
                let id = TagType.content.rawValue
                return #Predicate {
                    contents.contains($0.name) && $0.typeID == id
                }
            }
        }
    }
}

extension FetchDescriptor where T == Tag {
    static func tags(_ predicate: Tag.Predicate, order: SortOrder = .forward) -> FetchDescriptor {
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
