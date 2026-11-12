import Foundation

/// Template 1 represents the supported input fields of SwiftData schema 2.0.0.
enum ItemTemplateFormatV1 {
    enum Field: String, CaseIterable {
        case date = "Date"
        case content = "Content"
        case income = "Income"
        case outgo = "Outgo"
        case category = "Category"
        case priority = "Priority"
        case currency = "Currency"
    }

    static let formatVersion = 1
    static let schemaVersion = IncomesSchemaV2.versionIdentifier

    private static let headingPrefix = "## "
    private static let bulletPrefix = "- "
    private static let continuationPrefix = "  "

    static func input(
        from lines: [String],
        ledgerIdentifier: LedgerIdentifier,
        currencyCode: String
    ) throws -> ItemFormInput {
        let fields = try readFields(lines)
        guard fields[.currency] == currencyCode else {
            throw ItemTemplateError.currencyMismatch
        }
        guard let date = IncomesFileValueCoding.day(from: fields[.date] ?? "") else {
            throw ItemTemplateError.invalidField("Date")
        }
        guard let income = IncomesFileValueCoding.amount(from: fields[.income] ?? "") else {
            throw ItemTemplateError.invalidField("Income")
        }
        guard let outgo = IncomesFileValueCoding.amount(from: fields[.outgo] ?? "") else {
            throw ItemTemplateError.invalidField("Outgo")
        }
        guard let priorityText = fields[.priority], let priority = Int(priorityText),
              String(priority) == priorityText else {
            throw ItemTemplateError.invalidField("Priority")
        }
        let content = fields[.content] ?? ""
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ItemTemplateError.invalidField("Content")
        }
        let input = ItemFormInput(
            date: Calendar.current.shiftedDate(componentsFrom: date, in: .utc),
            content: content,
            income: income,
            outgo: outgo,
            category: fields[.category] ?? "",
            priority: priority,
            ledgerIdentifier: ledgerIdentifier
        )
        try input.validate()
        return input
    }

    static func body(_ fields: [Field: String]) throws -> String {
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
        return sections.joined(separator: "\n\n") + "\n"
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
