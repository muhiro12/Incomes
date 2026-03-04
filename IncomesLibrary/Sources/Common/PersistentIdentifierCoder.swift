import Foundation
import SwiftData

public enum PersistentIdentifierCoder {
    public static func decode(
        _ string: String
    ) throws -> PersistentIdentifier {
        guard let data = Data(base64Encoded: string) else {
            throw SwiftUtilitiesError.invalidBase64String
        }
        return try JSONDecoder().decode(PersistentIdentifier.self, from: data)
    }

    public static func encode(
        _ identifier: PersistentIdentifier
    ) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(identifier).base64EncodedString()
    }
}
