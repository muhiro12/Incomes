import Foundation

/// Provides stable language code resolution for generated text features.
public enum LocaleLanguageCodeSupport {
    /// Returns the locale language code, or `defaultCode` when it is unavailable.
    public static func code(
        for locale: Locale,
        defaultCode: String = "en"
    ) -> String {
        locale.language.languageCode?.identifier ?? defaultCode
    }

    /// Returns whether `locale` resolves to Japanese.
    public static func isJapanese(_ locale: Locale) -> Bool {
        code(for: locale) == "ja"
    }
}
