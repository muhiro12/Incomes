import Foundation

/// A bounded reader for the documented Markdown subset, not a general Markdown renderer.
enum ItemTemplateCodec {
    enum Field: String, CaseIterable {
        case date = "Date"
        case content = "Content"
        case income = "Income"
        case outgo = "Outgo"
        case category = "Category"
        case priority = "Priority"
        case currency = "Currency"
    }

    static let identifier = "# Incomes Item Template"
    static let version = "Template-Version: 1"
    private static let minimumFencedLineCount = 4
    private static let headingPrefix = "## "
    private static let bulletPrefix = "- "
    private static let continuationPrefix = "  "
    static let maximumByteCount = 16_384
    static let maximumLineCount = 512

    static func read(_ text: String) throws -> [Field: String] {
        try validateSize(text)
        var lines = text.replacingOccurrences(of: "\r\n", with: "\n")
            .components(separatedBy: "\n")
        while lines.first?.isEmpty == true {
            lines.removeFirst()
        }
        while lines.last?.isEmpty == true {
            lines.removeLast()
        }
        if lines.first == "```markdown" || lines.first == "```" {
            guard lines.count >= minimumFencedLineCount, lines.last == "```" else {
                throw ItemTemplateError.invalidStructure
            }
            lines.removeFirst()
            lines.removeLast()
        }
        guard lines.first == identifier else {
            throw ItemTemplateError.invalidStructure
        }
        lines.removeFirst()
        guard lines.first == version else {
            if lines.first?.hasPrefix("Template-Version:") == true {
                throw ItemTemplateError.unsupportedVersion
            }
            throw ItemTemplateError.invalidStructure
        }
        lines.removeFirst()
        return try readFields(lines)
    }

    static func write(_ fields: [Field: String]) throws -> String {
        var sections = [String]()
        for field in Field.allCases {
            let value = fields[field] ?? ""
            guard !value.contains("\r") else {
                throw ItemTemplateError.invalidField(field.rawValue)
            }
            let lines = value.components(separatedBy: "\n")
            let bullet = lines.enumerated()
                .map { index, line in
                    (index == .zero ? bulletPrefix : continuationPrefix) + line
                }
                .joined(separator: "\n")
            sections.append("## \(field.rawValue)\n\(bullet)")
        }
        let text = identifier + "\n" + version + "\n\n" + sections.joined(separator: "\n\n") + "\n"
        try validateSize(text)
        return text
    }

    private static func validateSize(_ text: String) throws {
        guard text.utf8.count <= maximumByteCount,
              text.components(separatedBy: "\n").count <= maximumLineCount else {
            throw ItemTemplateError.tooLarge
        }
    }

    private static func readFields(_ lines: [String]) throws -> [Field: String] {
        var fields = [Field: String]()
        var currentField: Field?
        for line in lines {
            if line.isEmpty {
                continue
            }
            if line.hasPrefix(headingPrefix) {
                let name = String(line.dropFirst(headingPrefix.count))
                guard let field = Field(rawValue: name) else {
                    throw ItemTemplateError.unknownField(name)
                }
                if let currentField, fields[currentField] == nil {
                    throw ItemTemplateError.invalidField(currentField.rawValue)
                }
                guard fields[field] == nil, currentField != field else {
                    throw ItemTemplateError.duplicateField(name)
                }
                currentField = field
            } else if let currentField, line.hasPrefix(bulletPrefix), fields[currentField] == nil {
                fields[currentField] = String(line.dropFirst(bulletPrefix.count))
            } else if let currentField, let value = fields[currentField], line.hasPrefix(continuationPrefix) {
                guard currentField == .content || currentField == .category else {
                    throw ItemTemplateError.invalidField(currentField.rawValue)
                }
                fields[currentField] = value + "\n" + line.dropFirst(continuationPrefix.count)
            } else {
                throw ItemTemplateError.invalidStructure
            }
        }
        for field in Field.allCases where fields[field] == nil {
            throw ItemTemplateError.missingField(field.rawValue)
        }
        return fields
    }
}
