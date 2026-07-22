import Foundation

/// Provides stable language code resolution for generated text features.
enum LocaleLanguageCodeSupport {
    /// Returns the locale language code, or `defaultCode` when it is unavailable.
    static func code(
        for locale: Locale,
        defaultCode: String = "en"
    ) -> String {
        locale.language.languageCode?.identifier ?? defaultCode
    }

    /// Returns whether `locale` resolves to Japanese.
    static func isJapanese(_ locale: Locale) -> Bool {
        code(for: locale) == "ja"
    }
}
