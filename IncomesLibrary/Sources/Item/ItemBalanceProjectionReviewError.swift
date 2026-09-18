import Foundation

/// Failures that stop a reviewed balance projection from being applied.
public enum ItemBalanceProjectionReviewError: LocalizedError, Equatable, Sendable, CaseIterable {
    /// The form values changed after the projection was reviewed.
    case draftChanged
    /// The reviewed item or repeat scope no longer matches the current entry.
    case targetChanged
    /// Stored records changed after the projection was reviewed.
    case baselineChanged
    /// The reviewed item is no longer stored.
    case reviewedItemUnavailable

    public var errorDescription: String? {
        switch self {
        case .draftChanged:
            return String(
                localized: "This entry changed after the last balance preview. Preview the balance again.",
                bundle: .module
            )
        case .targetChanged:
            return String(
                localized: "The last balance preview no longer matches this entry. Preview it again.",
                bundle: .module
            )
        case .baselineChanged:
            return String(
                localized: "Your records changed after the last balance preview. Preview the balance again.",
                bundle: .module
            )
        case .reviewedItemUnavailable:
            return String(
                localized: "The reviewed item is no longer available. Nothing was saved.",
                bundle: .module
            )
        }
    }
}
