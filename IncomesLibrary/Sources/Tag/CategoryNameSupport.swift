import Foundation

/// Shared semantic helpers for category names, including uncategorized values.
public enum CategoryNameSupport {
    /// Legacy stored name that also represents uncategorized items.
    public static let othersStoredName = "Others"

    private static let othersCanonicalKey = "__others__"

    /// User-facing label for uncategorized entries in the active locale.
    public static var localizedOthersDisplayName: String {
        String(localized: "Others")
    }

    /// True when the stored category should be treated as uncategorized.
    public static func isOthersLike(
        _ storedName: String?
    ) -> Bool {
        guard let storedName else {
            return true
        }

        return storedName.isEmpty || storedName == othersStoredName
    }

    /// Returns the user-facing label for a stored category value.
    public static func displayName(
        forStoredName storedName: String?,
        othersDisplayName: String = localizedOthersDisplayName
    ) -> String {
        if isOthersLike(storedName) {
            return othersDisplayName
        }

        return storedName.orEmpty
    }

    /// Returns the normalized stored value for user-entered category text.
    public static func normalizedStoredName(
        forUserInput userInput: String,
        othersDisplayName: String = localizedOthersDisplayName
    ) -> String {
        if isOthersInput(
            userInput,
            othersDisplayName: othersDisplayName
        ) {
            return .empty
        }

        return userInput
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

    /// True when the query should match the uncategorized bucket.
    public static func matchesOthersDisplayName(
        query: String,
        othersDisplayName: String = localizedOthersDisplayName
    ) -> Bool {
        localizedAliases(
            othersDisplayName: othersDisplayName
        )
        .contains { alias in
            alias.normalizedContains(query)
        }
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

    private static func isOthersInput(
        _ userInput: String,
        othersDisplayName: String
    ) -> Bool {
        if userInput.isEmpty {
            return true
        }

        return localizedAliases(
            othersDisplayName: othersDisplayName
        )
        .contains(userInput)
    }

    private static func localizedAliases(
        othersDisplayName: String
    ) -> [String] {
        [othersStoredName, othersDisplayName]
            .filter(\.isNotEmpty)
    }
}
