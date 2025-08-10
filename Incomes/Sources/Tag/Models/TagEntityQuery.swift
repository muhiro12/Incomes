//
//  TagEntityQuery.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/24.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData

@MainActor
struct TagEntityQuery: EntityStringQuery {
    @Dependency private var modelContainer: ModelContainer

    func entities(for identifiers: [TagEntity.ID]) throws -> [TagEntity] {
        try identifiers.compactMap { id in
            guard let tag = try TagService.getByID(
                context: modelContainer.mainContext,
                id: id
            ) else {
                return nil
            }
            return .init(tag)
        }
    }

    func entities(matching string: String) throws -> [TagEntity] {
        let tags = try TagService.getAll(context: modelContainer.mainContext)
        let hiragana = string.applyingTransform(.hiraganaToKatakana, reverse: true).orEmpty
        let katakana = string.applyingTransform(.hiraganaToKatakana, reverse: false).orEmpty
        return [
            TagType.year,
            .yearMonth,
            .content,
            .category
        ]
        .compactMap { type in
            guard let tag = tags.first(
                where: {
                    $0.type == type
                        && (
                            $0.name.localizedStandardContains(string)
                                || $0.name.localizedStandardContains(hiragana)
                                || $0.name.localizedStandardContains(katakana)
                        )
                }
            ) else {
                return nil
            }
            return .init(tag)
        }
    }

    func suggestedEntities() throws -> [TagEntity] {
        let tags = try TagService.getAll(context: modelContainer.mainContext)
        return [
            TagType.year,
            .yearMonth,
            .content,
            .category
        ]
        .compactMap { type in
            guard let tag = tags.first(
                where: {
                    $0.type == type
                }
            ) else {
                return nil
            }
            return .init(tag)
        }
    }
}
