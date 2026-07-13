import Foundation
@testable import IncomesLibrary
import Testing

struct LocaleLanguageCodeSupportTests {
    @Test
    func code_returns_locale_language_identifier() {
        #expect(
            LocaleLanguageCodeSupport.code(
                for: Locale(identifier: "ja_JP")
            ) == "ja"
        )
    }

    @Test
    func code_uses_default_when_language_code_is_missing() {
        #expect(
            LocaleLanguageCodeSupport.code(
                for: Locale(identifier: ""),
                defaultCode: "en"
            ) == "en"
        )
    }
}
