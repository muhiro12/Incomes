import Foundation

/// Documented for SwiftLint compliance.
public enum ReviewRequestPolicy {
    /// Documented for SwiftLint compliance.
    public static func shouldRequestReview(
        randomValue: Int,
        maxExclusive: Int
    ) -> Bool {
        guard maxExclusive > 0 else {
            return false
        }
        return randomValue == 0
    }
}
