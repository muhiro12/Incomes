//
//  TagDescriptors.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/10.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

extension Tag {
    typealias FetchDescriptor = SwiftData.FetchDescriptor<Tag>

    static func descriptor(sortBy order: SortOrder = defaultOrder) -> FetchDescriptor {
        descriptor(
            predicate: .true,
            sortBy: order
        )
    }

    static func descriptor(id: Tag.ID, sortBy order: SortOrder = defaultOrder) -> FetchDescriptor {
        descriptor(
            predicate: #Predicate {
                $0.persistentModelID == id
            },
            sortBy: order
        )
    }

    static func descriptor(isSameWith tag: Tag, sortBy order: SortOrder = defaultOrder) -> FetchDescriptor {
        let name = tag.name
        let typeID = tag.typeID
        return descriptor(
            predicate: #Predicate {
                $0.name == name && $0.typeID == typeID
            },
            sortBy: order
        )
    }

    static func descriptor(name: String, type: Tag.TagType, sortBy order: SortOrder = defaultOrder) -> FetchDescriptor {
        let id = type.rawValue
        return descriptor(
            predicate: #Predicate {
                $0.name == name && $0.typeID == id
            },
            sortBy: order
        )
    }

    static func descriptor(type: Tag.TagType, sortBy order: SortOrder = defaultOrder) -> FetchDescriptor {
        let id = type.rawValue
        return descriptor(
            predicate: #Predicate {
                $0.typeID == id
            },
            sortBy: order
        )
    }

    static func descriptor(year: String, sortBy order: SortOrder = defaultOrder) -> FetchDescriptor {
        let id = TagType.yearMonth.rawValue
        return descriptor(
            predicate: #Predicate {
                $0.name.starts(with: year) && $0.typeID == id
            },
            sortBy: order
        )
    }

    static func descriptor(dateIsSameMonthAs date: Date, sortBy order: SortOrder = defaultOrder) -> FetchDescriptor {
        let name = date.stringValueWithoutLocale(.yyyyMM)
        let id = TagType.yearMonth.rawValue
        return descriptor(
            predicate: #Predicate {
                $0.name == name && $0.typeID == id
            },
            sortBy: order
        )
    }

    static func descriptor(contents: [String], sortBy order: SortOrder = defaultOrder) -> FetchDescriptor {
        let id = TagType.content.rawValue
        return descriptor(
            predicate: #Predicate {
                contents.contains($0.name) && $0.typeID == id
            },
            sortBy: order
        )
    }
}

// MARK: - Private

private extension Tag {
    typealias Predicate = Foundation.Predicate<Tag>

    static var defaultOrder = SortOrder.forward

    static func descriptor(predicate: Predicate, sortBy order: SortOrder) -> FetchDescriptor {
        .init(
            predicate: predicate,
            sortBy: [
                .init(\.name, order: order),
                .init(\.typeID, order: order),
                .init(\.persistentModelID, order: order)
            ]
        )
    }
}
