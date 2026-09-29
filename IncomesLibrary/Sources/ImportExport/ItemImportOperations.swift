import Foundation

/// Reads Incomes files, compares them with the store, and applies reviewed imports.
public enum ItemImportOperations {
    /// Largest file accepted for import.
    public static let maximumFileByteCount = IncomesFileCodec.maximumByteCount

    /// Decodes and validates a file without touching the store; safe away from the model actor.
    public static func read(data: Data) throws -> IncomesFileContents {
        try IncomesFileCodec.decode(data)
    }
}
