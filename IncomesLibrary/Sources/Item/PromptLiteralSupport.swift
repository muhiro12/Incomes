import Foundation

enum PromptLiteralSupport {
    static func jsonStringLiteral(_ text: String) -> String {
        guard
            let data = try? JSONEncoder().encode(text),
            let literal = String(data: data, encoding: .utf8)
        else {
            assertionFailure()
            return "\"\""
        }

        return literal
    }
}
