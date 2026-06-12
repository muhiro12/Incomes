import Foundation

/// Helpers for semantic-like version string comparison (numeric).
enum VersionComparator {
    /// Returns true when `current` is numerically less than `required`.
    static func isUpdateRequired(current: String, required: String) -> Bool {
        current.compare(required, options: .numeric) == .orderedAscending
    }
}
