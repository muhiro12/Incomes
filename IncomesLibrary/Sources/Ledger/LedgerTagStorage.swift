import Foundation
import SwiftData

/// The existing type field carries portable identity; the name stays freely editable.
enum LedgerTagStorage {
    static let typePrefix = "ledger:"

    static func typeID(for identifier: LedgerIdentifier) -> String {
        typePrefix + identifier.rawValue
    }

    static func identifier(for tag: Tag) -> LedgerIdentifier? {
        guard tag.typeID.hasPrefix(typePrefix) else {
            return nil
        }
        let value = String(tag.typeID.dropFirst(typePrefix.count))
        guard !value.isEmpty, value != LedgerIdentifier.default.rawValue,
              value != LedgerIdentifier.conflicting.rawValue else {
            return nil
        }
        return .init(rawValue: value)
    }
}
