import Foundation

/// A rejected data mutation with app-owned recovery guidance.
public enum RemoteUpdateError: LocalizedError, CustomLocalizedStringResourceConvertible, Equatable, Sendable {
    case updateRequired
    case policyUnavailable

    public var errorDescription: String? {
        String(localized: localizedStringResource)
    }

    /// Preserves actionable failure text when Siri or Shortcuts presents the error.
    public var localizedStringResource: LocalizedStringResource {
        switch self {
        case .updateRequired:
            .init(
                "Please update Incomes to continue editing your data.",
                bundle: .atURL(Bundle.module.bundleURL)
            )
        case .policyUnavailable:
            .init(
                "Update requirements could not be verified. Connect to the internet and try again.",
                bundle: .atURL(Bundle.module.bundleURL)
            )
        }
    }
}
