import SwiftData

/// Current model names, preserving the historical date attribute identity.
public enum IncomesSchemaV3: VersionedSchema {
    // swiftlint:disable:next no_magic_numbers
    public static let versionIdentifier = Schema.Version(3, 0, 0)

    public static var models: [any PersistentModel.Type] {
        [Item.self, Tag.self]
    }
}
