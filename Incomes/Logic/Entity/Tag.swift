//
//  Tag.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2023/09/09.
//  Copyright © 2023 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Tag {
    enum TagType: String {
        case year = "aae8af65"
        case yearMonth = "27c9be4b"
        case content = "e2d390d9"
        case category = "a7a130f4"
    }

    private(set) var name = String.empty
    private(set) var typeID = String.empty

    private(set) var items: [Item]?

    init(name: String = String.empty, typeID: String = String.empty, items: [Item]? = nil) {
        self.name = name
        self.typeID = typeID
    }
}

extension Tag {
    var type: TagType? {
        TagType(rawValue: typeID)
    }
}

extension Tag: Equatable {
    static func == (lhs: Tag, rhs: Tag) -> Bool {
        lhs.name == rhs.name && lhs.typeID == rhs.typeID
    }
}
