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
        case category = "a7a130f4"
    }

    private(set) var name = String.empty
    private(set) var typeID = String.empty

    private(set) var items: [Item]?

    init(_ name: String, for type: TagType) {
        self.name = name
        self.typeID = type.rawValue
    }
}

extension Tag: Equatable {
    static func == (lhs: Tag, rhs: Tag) -> Bool {
        lhs.name == rhs.name && lhs.typeID == rhs.typeID
    }
}
