import CryptoKit
import Foundation
import SwiftData

/// Additional books use native Tag identity; standard Tags share the reserved default role.
enum LedgerTagStorage {
    static let defaultLedgerStoredName = "Default Ledger"

    static func customDefaultLedgerName(in tags: [Tag]) -> String? {
        tags.filter { $0.type == .defaultLedger }
            .map { $0.name.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0 != defaultLedgerStoredName }
            .min()
    }

    static func identifier(for tag: Tag) -> LedgerIdentifier? {
        if tag.type == .defaultLedger {
            return .default
        }
        guard tag.type == .ledger,
              let value = try? PersistentIdentifierCoder.encode(tag.persistentModelID) else {
            return nil
        }
        return .init(rawValue: value)
    }

    /// Stable within the source store without exposing its persistent-ID payload in a file.
    static func fileReference(for identifier: LedgerIdentifier) -> LedgerIdentifier {
        guard identifier != .default, identifier != .conflicting, identifier != .unassigned else {
            return identifier
        }
        let input = Data(("Incomes ledger file reference v1|" + identifier.rawValue).utf8)
        let digest = SHA256.hash(data: input).map { String(format: "%02x", $0) }.joined()
        return .init(rawValue: "ledger-" + digest)
    }
}
