import Foundation

/// Resolves user-facing error messages with a localized-error preference.
public enum ErrorMessageSupport {
    /// Returns `LocalizedError.errorDescription` when available, otherwise `localizedDescription`.
    public static func message(from error: Error) -> String {
        if let localizedError = error as? LocalizedError,
           let description = localizedError.errorDescription {
            return description
        }
        return error.localizedDescription
    }
}
