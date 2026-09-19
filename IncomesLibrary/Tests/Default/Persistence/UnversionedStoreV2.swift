import Foundation
import SwiftData

// Independent unversioned fixture matching the persisted declarations in tag 5.12.
// Keep this frozen: seeding through the production versioned schema would hide drift.
enum UnversionedStoreV2 {
    @Model
    final class Item {
        var date = Date(timeIntervalSinceReferenceDate: .zero)
        var content = ""
        var income = Decimal.zero
        var outgo = Decimal.zero
        var priority = 0
        var repeatID = UUID()
        var balance = Decimal.zero

        @Relationship(inverse: \Tag.items)
        var tags: [Tag]? // swiftlint:disable:this discouraged_optional_collection

        init() {
            // Populate synthetic historical records after insertion.
        }
    }

    @Model
    final class Tag {
        var name = ""
        var typeID = ""
        var items: [Item]? // swiftlint:disable:this discouraged_optional_collection

        init() {
            // Populate synthetic historical records after insertion.
        }
    }
}
