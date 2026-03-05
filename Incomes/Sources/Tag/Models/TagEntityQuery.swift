//
//  TagEntityQuery.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/24.
//

import AppIntents
import SwiftData

struct TagEntityQuery: EntityStringQuery {
    @Dependency private var modelContainer: ModelContainer

    @MainActor
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

    @MainActor
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
                where: { item in
                    item.type == type
                        && (
                            item.name.localizedStandardContains(string)
                                || item.name.localizedStandardContains(hiragana)
                                || item.name.localizedStandardContains(katakana)
                        )
                }
            ) else {
                return nil
            }
            return .init(tag)
        }
    }

    @MainActor
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
                where: { item in
                    item.type == type
                }
            ) else {
                return nil
            }
            return .init(tag)
        }
    }
}
