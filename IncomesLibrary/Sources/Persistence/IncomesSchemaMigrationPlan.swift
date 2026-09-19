import SwiftData

/// Historical store versions, independent of the app's marketing version.
public enum IncomesSchemaMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] {
        [IncomesSchemaV0.self, IncomesSchemaV1.self, IncomesSchemaV2.self, IncomesSchemaV3.self]
    }

    public static var stages: [MigrationStage] {
        [
            .lightweight(fromVersion: IncomesSchemaV0.self, toVersion: IncomesSchemaV1.self),
            .lightweight(fromVersion: IncomesSchemaV1.self, toVersion: IncomesSchemaV2.self),
            .lightweight(fromVersion: IncomesSchemaV2.self, toVersion: IncomesSchemaV3.self)
        ]
    }
}
