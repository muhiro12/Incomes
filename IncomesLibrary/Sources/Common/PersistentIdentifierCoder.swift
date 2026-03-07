import Foundation
import SwiftData

/// Encodes and decodes `PersistentIdentifier` values as Base64 strings.
public enum PersistentIdentifierCoder {
    /// Decodes a Base64 string into a `PersistentIdentifier`.
    public static func decode(
        _ string: String
    ) throws -> PersistentIdentifier {
        guard let data = Data(base64Encoded: string) else {
            throw SwiftUtilitiesError.invalidBase64String
        }
        return try JSONDecoder().decode(PersistentIdentifier.self, from: data)
    }

    /// Encodes a `PersistentIdentifier` into a stable Base64 string.
    public static func encode(
        _ identifier: PersistentIdentifier
    ) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(identifier).base64EncodedString()
    }
}
