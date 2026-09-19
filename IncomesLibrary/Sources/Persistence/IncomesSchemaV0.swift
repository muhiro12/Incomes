import Foundation
import SwiftData

/// Frozen persisted model shape shipped in Incomes 2.0 through 2.4.2.
enum IncomesSchemaV0: VersionedSchema {
    static let versionIdentifier = Schema.Version(0, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Item.self, Tag.self]
    }
}

extension IncomesSchemaV0 {
    @Model
    final class Item {
        private(set) var date = Date(timeIntervalSinceReferenceDate: .zero)
        private(set) var content = ""
        private(set) var income = Decimal.zero
        private(set) var outgo = Decimal.zero
        private(set) var repeatID = UUID()
        private(set) var balance = Decimal.zero
        private(set) var group = ""
        private(set) var startOfYear = Date(timeIntervalSinceReferenceDate: .zero)

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
