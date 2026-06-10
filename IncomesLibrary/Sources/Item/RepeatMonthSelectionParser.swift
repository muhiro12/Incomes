import Foundation

/// Parses repeat month selections from user-facing text.
public enum RepeatMonthSelectionParser {
    /// Parse error for invalid repeat month text.
    public enum ParserError: Error, Equatable, Sendable {
        case invalidToken(String)
    }

    /// Parses text such as `202501, 2025-02` into repeat month selections.
    public static func parse(_ value: String) throws -> Set<RepeatMonthSelection> {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedValue.isNotEmpty else {
            return []
        }

        let tokens = trimmedValue
            .split { character in
                character == "," || character.isWhitespace
            }
            .map(String.init)

        var selections = Set<RepeatMonthSelection>()
        for token in tokens {
            let compactValue = token.replacingOccurrences(of: "-", with: "")
            guard compactValue.count == YearMonthComponentRules.compactYearMonthDigitCount,
                  let year = Int(compactValue.prefix(YearMonthComponentRules.yearDigitCount)),
                  let month = Int(compactValue.suffix(YearMonthComponentRules.monthDigitCount)),
                  YearMonthComponentRules.isValidYear(year),
                  YearMonthComponentRules.isValidMonth(month) else {
                throw ParserError.invalidToken(token)
            }
            selections.insert(.init(year: year, month: month))
        }

        return selections
    }
}
