import Foundation

struct FoundationModelPromptTemplate {
    let resourceName: String

    func render(replacements: [String: String] = [:]) -> String {
        let template = Self.load(resourceName: resourceName)
        let placeholders = Self.placeholders(in: template)
        let missingPlaceholders = placeholders.subtracting(replacements.keys)

        precondition(
            missingPlaceholders.isEmpty,
            "Missing Foundation Models prompt replacement(s): \(missingPlaceholders.sorted())"
        )

        var renderedTemplate = template
        for (key, value) in replacements {
            renderedTemplate = renderedTemplate.replacingOccurrences(
                of: "{{\(key)}}",
                with: value
            )
        }
        return renderedTemplate
    }
}

private extension FoundationModelPromptTemplate {
    static func load(resourceName: String) -> String {
        guard let url = Bundle.module.url(
            forResource: resourceName,
            withExtension: "prompt"
        ) else {
            preconditionFailure("Missing Foundation Models prompt resource: \(resourceName).prompt")
        }

        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            preconditionFailure("Failed to read Foundation Models prompt resource: \(error)")
        }
    }

    static func placeholders(in template: String) -> Set<String> {
        let pattern = #"\{\{([A-Za-z0-9_]+)\}\}"#
        guard let expression = try? NSRegularExpression(pattern: pattern) else {
            return []
        }

        let range = NSRange(template.startIndex..<template.endIndex, in: template)
        let matches = expression.matches(in: template, range: range)

        return Set(matches.compactMap { match in
            guard let placeholderRange = Range(match.range(at: 1), in: template) else {
                return nil
            }
            return String(template[placeholderRange])
        })
    }
}
