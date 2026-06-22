@testable import IncomesLibrary
import Testing

struct PromptLiteralSupportTests {
    @Test
    func jsonStringLiteral_preserves_plain_text_as_json_string() {
        let literal = PromptLiteralSupport.jsonStringLiteral("Lunch yesterday 1200 yen")

        #expect(literal == #""Lunch yesterday 1200 yen""#)
    }

    @Test
    func jsonStringLiteral_escapes_structural_characters() {
        let literal = PromptLiteralSupport.jsonStringLiteral("Lunch \"yesterday\"\nBackslash \\")

        #expect(literal == #""Lunch \"yesterday\"\nBackslash \\""#)
    }
}
