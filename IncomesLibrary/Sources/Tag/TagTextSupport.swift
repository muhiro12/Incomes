import Foundation

/// Shared formatting and matching helpers for derived tag text.
public enum TagTextSupport {
    /// Returns the user-facing label for a stored tag name and type.
    public static func displayName(
        name: String,
        type: TagType?
    ) -> String {
        switch type {
        case .year:
            name.dateValueWithoutLocale(.yyyy)?.stringValue(.yyyy) ?? name
        case .yearMonth:
            name.dateValueWithoutLocale(.yyyyMM)?.stringValue(.yyyyMMM) ?? name
        case .content:
            name
        case .category:
            CategoryNameSupport.displayName(forStoredName: name)
        case .debug:
            name
        case .none:
            name
        }
    }

    /// Matches a query against the stored tag name, including kana variants.
    public static func matchesStoredName(
        _ storedName: String,
        query: String
    ) -> Bool {
        let variants = storedNameQueryVariants(for: query)
        return storedName.localizedStandardContains(variants.raw)
            || storedName.localizedStandardContains(variants.hiragana)
            || storedName.localizedStandardContains(variants.katakana)
    }

    /// Matches a query against the rendered display name for a tag.
    public static func matchesDisplayName(
        name: String,
        type: TagType?,
        query: String
    ) -> Bool {
        displayName(
            name: name,
            type: type
        )
        .normalizedContains(query)
    }
}

extension TagTextSupport {
    struct StoredNameQueryVariants {
        let raw: String
        let hiragana: String
        let katakana: String
    }

    static func storedNameQueryVariants(
        for query: String
    ) -> StoredNameQueryVariants {
        .init(
            raw: query,
            hiragana: query.applyingTransform(
                .hiraganaToKatakana,
                reverse: true
            ).orEmpty,
            katakana: query.applyingTransform(
                .hiraganaToKatakana,
                reverse: false
            ).orEmpty
        )
    }
}
