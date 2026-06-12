import Foundation

/// Shared helper that applies localized-error preference rules.
enum ErrorMessageSupport {
    static func message(from error: Error) -> String {
        if let localizedError = error as? LocalizedError,
           let description = localizedError.errorDescription {
            return description
        }
        return error.localizedDescription
    }
}
