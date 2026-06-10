//
//  TagEntity.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/24.
//

import AppIntents
import SwiftData

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
    let displayName: String

    init(id: String, name: String, typeID: String, displayName: String) {
        self.id = id
        self.name = name
        self.typeID = typeID
        self.displayName = displayName
    }
}

extension TagEntity {
    convenience init?(_ model: Tag) {
        guard let encodedID = try? PersistentIdentifierCoder.encode(model.id) else {
            return nil
        }
        self.init(
            id: encodedID,
            name: model.name,
            typeID: model.typeID,
            displayName: model.displayName
        )
    }

    static func make(from model: Tag) throws -> TagEntity {
        guard let entity = TagEntity(model) else {
            throw TagEntityError.conversionFailed
        }
        return entity
    }

    static func make(from models: [Tag]) throws -> [TagEntity] {
        try models.map { model in
            try make(from: model)
        }
    }
}

extension TagEntity: Hashable {
    static func == (lhs: TagEntity, rhs: TagEntity) -> Bool {
        guard let lID = try? PersistentIdentifierCoder.decode(lhs.id),
              let rID = try? PersistentIdentifierCoder.decode(rhs.id) else {
            return false
        }
        return lID == rID
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension TagEntity {
    var type: TagType? {
        TagType(rawValue: typeID)
    }

    func model(in context: ModelContext) throws -> Tag {
        guard let model = try TagQueryOperations.getByID(
            context: context,
            id: id
        ) else {
            throw TagEntityError.tagNotFound
        }
        return model
    }
}
