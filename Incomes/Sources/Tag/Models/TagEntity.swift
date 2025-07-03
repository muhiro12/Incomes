//
//  TagEntity.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/24.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import AppIntents
import SwiftData
import SwiftUtilities

@Observable
final class TagEntity: AppEntity {
    static let defaultQuery = TagEntityQuery()

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(
            name: .init("Tag", table: "AppIntents"),
            numericFormat: LocalizedStringResource("\(placeholder: .int) Tags", table: "AppIntents")
        )
    }

    var displayRepresentation: DisplayRepresentation {
        .init(
            title: .init("\(displayName)", table: "AppIntents"),
            image: .init(systemName: "tag.fill"),
            synonyms: [
                .init("\(name)", table: "AppIntents")
            ]
        )
    }

    let id: String
    let name: String
    let typeID: String

    init(id: String, name: String, typeID: String) {
        self.id = id
        self.name = name
        self.typeID = typeID
    }
}

// MARK: - ModelBridgeable

extension TagEntity: ModelBridgeable {
    typealias Model = Tag

    convenience init?(_ model: Tag) {
        guard let encodedID = try? model.id.base64Encoded() else {
            return nil
        }
        self.init(
            id: encodedID,
            name: model.name,
            typeID: model.typeID
        )
    }
}

extension TagEntity: Hashable {
    static func == (lhs: TagEntity, rhs: TagEntity) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension TagEntity {
    var type: TagType? {
        TagType(rawValue: typeID)
    }

    var displayName: String {
        switch type {
        case .year:
            name.dateValueWithoutLocale(.yyyy)?.stringValue(.yyyy) ?? name
        case .yearMonth:
            name.dateValueWithoutLocale(.yyyyMM)?.stringValue(.yyyyMMM) ?? name
        case .content:
            name
        case .category:
            name.isNotEmpty ? name : "Others"
        case .none:
            name
        }
    }

    func model(in context: ModelContext) throws -> Tag {
        guard
            let id = try? PersistentIdentifier(base64Encoded: id),
            let model = try context.fetchFirst(.tags(.idIs(id)))
        else {
            throw TagError.tagNotFound
        }
        return model
    }
}
