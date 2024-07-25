//
//  TagExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/10.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

// MARK: - FetchDescriptor

extension Tag {
    typealias FetchDescriptor = SwiftData.FetchDescriptor<Tag>
    typealias Predicate = Foundation.Predicate<Tag>

    static func descriptor(predicate: Predicate = .true, order: SortOrder = .forward) -> FetchDescriptor {
        .init(predicate: predicate, sortBy: sortDescriptors(order: .forward))
    }

    static func descriptor(id: Tag.ID) -> FetchDescriptor {
        descriptor(
            predicate: #Predicate {
                $0.persistentModelID == id
            }
        )
    }

    static func descriptor(isSameWith tag: Tag) -> FetchDescriptor {
        let name = tag.name
        let typeID = tag.typeID
        return descriptor(
            predicate: #Predicate {
                $0.name == name && $0.typeID == typeID
            }
        )
    }

    static func descriptor(name: String, type: Tag.TagType) -> FetchDescriptor {
        let id = type.rawValue
        return descriptor(
            predicate: #Predicate {
                $0.name == name && $0.typeID == id
            }
        )
    }

    static func descriptor(type: Tag.TagType, order: SortOrder = .forward) -> FetchDescriptor {
        let id = type.rawValue
        return descriptor(
            predicate: #Predicate {
                $0.typeID == id
            },
            order: order
        )
    }

    static func descriptor(year: String, order: SortOrder = .forward) -> FetchDescriptor {
        let id = TagType.yearMonth.rawValue
        return descriptor(
            predicate: #Predicate {
                $0.name.starts(with: year) && $0.typeID == id
            },
            order: order
        )
    }

    static func descriptor(dateIsSameMonthAs date: Date) -> FetchDescriptor {
        let name = date.stringValueWithoutLocale(.yyyyMM)
        let id = TagType.yearMonth.rawValue
        return descriptor(
            predicate: #Predicate {
                $0.name == name && $0.typeID == id
            }
        )
    }

    static func descriptor(contents: [String]) -> FetchDescriptor {
        let id = TagType.content.rawValue
        return descriptor(
            predicate: #Predicate {
                contents.contains($0.name) && $0.typeID == id
            }
        )
    }
}

// MARK: - SortDescriptor

private extension Tag {
    typealias SortDescriptor = Foundation.SortDescriptor<Tag>

    static func sortDescriptors(order: SortOrder) -> [SortDescriptor] {
        [.init(\.name, order: order),
         .init(\.typeID, order: order),
         .init(\.persistentModelID, order: order)]
    }
}
