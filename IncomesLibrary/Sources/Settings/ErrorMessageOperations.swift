import Foundation

/// Resolves user-facing error messages for presentation surfaces.
public enum ErrorMessageOperations {
    /// Returns `LocalizedError.errorDescription` when available, otherwise `localizedDescription`.
    public static func message(from error: Error) -> String {
        ErrorMessageSupport.message(from: error)
    }
}
