//
//  IncomesMigrationPlan.swift
//  Incomes
//
//  Created by Hiromu Nakano on 2025/05/20.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import Foundation
import SwiftData

enum IncomesMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [IncomesSchemaV1.self, IncomesSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }

    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: IncomesSchemaV1.self,
        toVersion: IncomesSchemaV2.self
    )
}

enum IncomesSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Item.self, Tag.self]
    }

    @Model
    final class Item {
        @Attribute(originalName: "date")
        private(set) var utcDate = Date(timeIntervalSinceReferenceDate: .zero)
        private(set) var content = String.empty
        private(set) var income = Decimal.zero
        private(set) var outgo = Decimal.zero
        private(set) var repeatID = UUID()
        private(set) var balance = Decimal.zero

        @Relationship(inverse: \Tag.items)
        private(set) var tags: [Tag]?

        private init() {}
    }

    @Model
    final class Tag {
        private(set) var name = String.empty
        private(set) var typeID = String.empty

        private(set) var items: [Item]?

        private init() {}
    }
}

enum IncomesSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Item.self, Tag.self]
    }

    @Model
    final class Item {
        private(set) var date = Date(timeIntervalSinceReferenceDate: .zero)
        private(set) var content = String.empty
        private(set) var income = Decimal.zero
        private(set) var outgo = Decimal.zero
        private(set) var repeatID = UUID()
        private(set) var balance = Decimal.zero

        @Relationship(inverse: \Tag.items)
        private(set) var tags: [Tag]?

        private init() {}
    }

    @Model
    final class Tag {
        private(set) var name = String.empty
        private(set) var typeID = String.empty

        private(set) var items: [Item]?

        private init() {}
    }
}
