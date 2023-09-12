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

    static func predicate(_ name: String, for type: Tag.TagType) -> Predicate {
        let id = type.rawValue
        return #Predicate {
        $0.name == name && $0.typeID == id
        }
    }

    static func predicate(for type: Tag.TagType) -> Predicate {
        let id = type.rawValue
        return #Predicate {
        $0.typeID == id
        }
    }
}

// MARK: - SortDescriptor

extension Tag {
    typealias SortDescriptor = Foundation.SortDescriptor<Tag>

    static func sortDescriptors() -> [SortDescriptor] {
        [.init(\.name),
         .init(\.typeID),
         .init(\.persistentModelID)]
    }
}
