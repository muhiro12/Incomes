import Foundation

/// Reasons an Incomes file cannot be written without changing the store.
public enum ItemExportError: LocalizedError, Equatable, Sendable {
    case fileTooLarge

    public var errorDescription: String? {
        switch self {
        case .fileTooLarge:
            String(
                localized: "Your data exceeds the file size supported by this version of Incomes.",
                bundle: .module
            )
        }
    }
}
