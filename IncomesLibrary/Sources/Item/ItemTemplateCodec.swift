import Foundation

/// Dispatches supported template-format and schema pairs before interpreting fields.
enum ItemTemplateCodec {
    static let identifier = "# Incomes Item Template"
    static let maximumByteCount = 16_384
    static let maximumLineCount = 512

    private static let minimumFencedLineCount = 5
    private static let headerLineCount = 3
    private static let formatPrefix = "Template-Version: "
    private static let schemaPrefix = "Schema-Version: "

    static func read(
        _ text: String,
        ledgerIdentifier: LedgerIdentifier,
        currencyCode: String
    ) throws -> ItemFormInput {
        try validateSize(text)
        var lines = text.replacingOccurrences(of: "\r\n", with: "\n")
            .components(separatedBy: "\n")
        guard !lines.contains(where: { $0.contains("\r") }) else {
            throw ItemTemplateError.invalidStructure
        }
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
        guard lines.count >= headerLineCount, lines.first == identifier else {
            throw ItemTemplateError.invalidStructure
        }
        lines.removeFirst()
        let formatText = try headerValue(lines.removeFirst(), prefix: formatPrefix)
        let schemaText = try headerValue(lines.removeFirst(), prefix: schemaPrefix)
        guard let formatVersion = Int(formatText), formatVersion > .zero,
              String(formatVersion) == formatText,
              let schemaVersion = IncomesFileValueCoding.version(from: schemaText),
              IncomesFileValueCoding.versionString(from: schemaVersion) == schemaText else {
            throw ItemTemplateError.invalidStructure
        }
        switch (formatVersion, schemaVersion) {
        case (ItemTemplateFormatV1.formatVersion, ItemTemplateFormatV1.schemaVersion):
            return try ItemTemplateFormatV1.input(
                from: lines,
                ledgerIdentifier: ledgerIdentifier,
                currencyCode: currencyCode
            )
        default:
            throw ItemTemplateError.unsupportedVersion
        }
    }

    static func write(_ fields: [ItemTemplateFormatV1.Field: String]) throws -> String {
        let formatVersion = ItemTemplateFormatV1.formatVersion
        let schemaVersion = IncomesFileValueCoding.versionString(from: ItemTemplateFormatV1.schemaVersion)
        let body = try ItemTemplateFormatV1.body(fields)
        let text = "\(identifier)\n\(formatPrefix)\(formatVersion)\n\(schemaPrefix)\(schemaVersion)\n\n\(body)"
        try validateSize(text)
        return text
    }

    private static func headerValue(_ line: String, prefix: String) throws -> String {
        guard line.hasPrefix(prefix) else {
            throw ItemTemplateError.invalidStructure
        }
        return String(line.dropFirst(prefix.count))
    }

    private static func validateSize(_ text: String) throws {
        guard text.utf8.count <= maximumByteCount,
              text.components(separatedBy: "\n").count <= maximumLineCount else {
            throw ItemTemplateError.tooLarge
        }
    }
}
