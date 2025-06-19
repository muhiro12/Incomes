//
//  TagType.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/06/18.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import Foundation

enum TagType: String {
    case year = "aae8af65"
    case yearMonth = "27c9be4b"
    case content = "e2d390d9"
    case category = "a7a130f4"
}

extension TagType: AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(name: "Tag Type")
    }

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [
            .year: .init(title: "Year"),
            .yearMonth: .init(title: "Year/Month"),
            .content: .init(title: "Content"),
            .category: .init(title: "Category")
        ]
    }
}
