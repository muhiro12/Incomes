//
//  TagEntityQuery.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/24.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents

struct TagEntityQuery: EntityStringQuery, @unchecked Sendable {
    @Dependency private var tagService: TagService

    func entities(for identifiers: [TagEntity.ID]) throws -> [TagEntity] {
        try identifiers.compactMap { id in
            try tagService.tag(
                .tags(.idIs(try .init(base64Encoded: id)))
            )
        }
        .compactMap(TagEntity.init)
    }

    func entities(matching string: String) throws -> [TagEntity] {
        try [
            Tag.TagType.year,
            .yearMonth,
            .content,
            .category
        ]
        .compactMap { type in
            try tagService.tag(
                .tags(.nameContains(string, type: type))
            )
        }
        .compactMap(TagEntity.init)
    }

    func suggestedEntities() throws -> [TagEntity] {
        try [
            Tag.TagType.year,
            .yearMonth,
            .content,
            .category
        ]
        .compactMap { type in
            try tagService.tag(
                .tags(.typeIs(type))
            )
        }
        .compactMap(TagEntity.init)
    }
}

