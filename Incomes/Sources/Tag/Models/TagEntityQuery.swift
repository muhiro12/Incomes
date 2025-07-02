//
//  TagEntityQuery.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/24.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

struct TagEntityQuery: EntityStringQuery {
    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func entities(for identifiers: [TagEntity.ID]) throws -> [TagEntity] {
        try identifiers.compactMap { id in
            try GetTagByIDIntent.perform(
                (
                    container: modelContainer,
                    id: id
                )
            )
        }
    }

    @MainActor
    func entities(matching string: String) throws -> [TagEntity] {
        let tags = try GetAllTagsIntent.perform(modelContainer)
        let hiragana = string.applyingTransform(.hiraganaToKatakana, reverse: true).orEmpty
        let katakana = string.applyingTransform(.hiraganaToKatakana, reverse: false).orEmpty
        return [
            TagType.year,
            .yearMonth,
            .content,
            .category
        ]
        .compactMap { type in
            tags.first {
                $0.type == type
                    && (
                        $0.name.localizedStandardContains(string)
                            || $0.name.localizedStandardContains(hiragana)
                            || $0.name.localizedStandardContains(katakana)
                    )
            }
        }
    }

    @MainActor
    func suggestedEntities() throws -> [TagEntity] {
        let tags = try GetAllTagsIntent.perform(modelContainer)
        return [
            TagType.year,
            .yearMonth,
            .content,
            .category
        ]
        .compactMap { type in
            tags.first {
                $0.type == type
            }
        }
    }
}
