import Foundation

/// Shared semantic helpers for category names, including uncategorized values.
public enum CategoryNameSupport {
    /// User-facing label for uncategorized entries.
    public static let othersDisplayName = "Others"

    private static let othersCanonicalKey = "__others__"

    /// True when the stored category should be treated as uncategorized.
    public static func isOthersLike(
        _ storedName: String?
    ) -> Bool {
        guard let storedName else {
            return true
        }

        return storedName.isEmpty || storedName == othersDisplayName
    }

    /// Returns the user-facing label for a stored category value.
    public static func displayName(
        forStoredName storedName: String?
    ) -> String {
        if isOthersLike(storedName) {
            return othersDisplayName
        }

        return storedName.orEmpty
    }

    /// True when two stored category values represent the same user-facing meaning.
    public static func areEquivalent(
        _ lhs: String?,
        _ rhs: String?
    ) -> Bool {
        if isOthersLike(lhs) {
            return isOthersLike(rhs)
        }

        return lhs == rhs
    }
}

extension CategoryNameSupport {
    static func canonicalKey(
        forStoredName storedName: String?
    ) -> String {
        if isOthersLike(storedName) {
            return othersCanonicalKey
        }

        return storedName.orEmpty
    }
}
