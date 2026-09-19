import SwiftData

/// Frozen persisted model shape shipped from Incomes 5.3, including item priority.
/// Model declarations live in Item.swift and Tag.swift under this namespace.
public enum IncomesSchemaV2: VersionedSchema {
    // swiftlint:disable:next no_magic_numbers
    public static let versionIdentifier = Schema.Version(2, 0, 0)

    public static var models: [any PersistentModel.Type] {
        [Item.self, Tag.self]
    }
}
