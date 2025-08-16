//
//  TagType+AppIntents.swift
//  Incomes
//
//  Created by Codex on 2025/08/16.
//

import AppIntents
import IncomesLibrary

extension TagType: @retroactive AppEnum {
    public static var allCases: [TagType] {
        [.year, .yearMonth, .content, .category]
    }

    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(name: "Tag Type")
    }

    public static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [
            .year: .init(title: "Year"),
            .yearMonth: .init(title: "Year/Month"),
            .content: .init(title: "Content"),
            .category: .init(title: "Category")
        ]
    }
}
