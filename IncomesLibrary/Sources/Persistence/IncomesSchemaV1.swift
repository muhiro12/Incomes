import Foundation
import SwiftData

/// Frozen persisted model shape shipped in Incomes 2.5 through 5.2.
enum IncomesSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Item.self, Tag.self]
    }
}

extension IncomesSchemaV1 {
    @Model
    final class Item {
        private(set) var date = Date(timeIntervalSinceReferenceDate: .zero)
        private(set) var content = ""
        private(set) var income = Decimal.zero
        private(set) var outgo = Decimal.zero
        private(set) var repeatID = UUID()
        private(set) var balance = Decimal.zero

        @Relationship(inverse: \Tag.items)
        private(set) var tags: [Tag]? // swiftlint:disable:this discouraged_optional_collection

        private init() {
            // Used only to describe historical stores.
        }
    }

    @Model
    final class Tag {
        private(set) var name = ""
        private(set) var typeID = ""
        private(set) var items: [Item]? // swiftlint:disable:this discouraged_optional_collection

        private init() {
            // Used only to describe historical stores.
        }
    }
}
