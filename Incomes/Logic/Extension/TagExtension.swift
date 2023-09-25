//
//  TagExtension.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/10.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation

// MARK: - Predicate

extension Tag {
    typealias Predicate = Foundation.Predicate<Tag>

    static func predicate(id: Tag.ID) -> Predicate {
        #Predicate {
            $0.persistentModelID == id
        }
    }

    static func predicate(name: String, type: Tag.TagType) -> Predicate {
        let id = type.rawValue
        return #Predicate {
            $0.name == name && $0.typeID == id
        }
    }

    static func predicate(type: Tag.TagType) -> Predicate {
        let id = type.rawValue
        return #Predicate {
            $0.typeID == id
        }
    }

    static func predicate(year: String) -> Predicate {
        let id = TagType.yearMonth.rawValue
        return #Predicate {
            $0.name.starts(with: year) && $0.typeID == id
        }
    }

    static func predicate(dateIsSameMonthAs date: Date) -> Predicate {
        let name = date.stringValueWithoutLocale(.yyyyMM)
        let id = TagType.yearMonth.rawValue
        return #Predicate {
            $0.name == name && $0.typeID == id
        }
    }

    static func predicate(contents: [String]) -> Predicate {
        let id = TagType.content.rawValue
        return #Predicate {
            contents.contains($0.name) && $0.typeID == id
        }
    }
}

// MARK: - SortDescriptor

extension Tag {
    typealias SortDescriptor = Foundation.SortDescriptor<Tag>

    static func sortDescriptors(order: SortOrder = .forward) -> [SortDescriptor] {
        switch order {
        case .forward:
            return [.init(\.name),
                    .init(\.typeID),
                    .init(\.persistentModelID)]

        case .reverse:
            return [.init(\.persistentModelID, order: .reverse),
                    .init(\.typeID, order: .reverse),
                    .init(\.name, order: .reverse)]
        }
    }
}
