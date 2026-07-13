import Foundation

private enum DecimalTextParser {
    private static func parsingLocales(
        primaryLocale: Locale
    ) -> [Locale] {
        let fixedGroupingLocale = Locale(identifier: "en_US")

        guard primaryLocale.identifier != fixedGroupingLocale.identifier else {
            return [fixedGroupingLocale]
        }

        return [primaryLocale, fixedGroupingLocale]
    }

    static func parse(
        _ text: String,
        locale: Locale
    ) -> Decimal? {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedText.isEmpty else {
            return nil
        }

        for parsingLocale in parsingLocales(primaryLocale: locale) {
            if let decimal = parseComplete(
                trimmedText,
                locale: parsingLocale
            ) {
                return decimal
            }
        }

        return nil
    }

    private static func parseComplete(
        _ text: String,
        locale: Locale
    ) -> Decimal? {
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.locale = locale
        formatter.numberStyle = .decimal
        var parsedObject: AnyObject?
        var parsedRange = NSRange(
            location: .zero,
            length: text.utf16.count
        )

        do {
            try formatter.getObjectValue(
                &parsedObject,
                for: text,
                range: &parsedRange
            )
        } catch {
            return nil
        }

        guard parsedRange.location == .zero,
              parsedRange.length == text.utf16.count else {
            return nil
        }

        guard parsedObject != nil,
              let normalizedText = normalizedDecimalText(
                text,
                formatter: formatter
              ) else {
            return nil
        }

        return Decimal(
            string: normalizedText,
            locale: Locale(identifier: "en_US_POSIX")
        )
    }

    static func normalizedDecimalText(
        _ text: String,
        formatter: NumberFormatter
    ) -> String? {
        var normalizedText = text

        for (source, replacement) in [
            (formatter.groupingSeparator, ""),
            (formatter.decimalSeparator, "."),
            (formatter.plusSign, "+"),
            (formatter.minusSign, "-")
        ] {
            guard let source,
                  !source.isEmpty,
                  source != replacement else {
                continue
            }
            normalizedText = normalizedText.replacingOccurrences(
                of: source,
                with: replacement
            )
        }

        var asciiText = ""
        var digitCount = 0
        var decimalSeparatorCount = 0

        for (index, character) in normalizedText.enumerated() {
            if let digit = character.wholeNumberValue {
                asciiText.append(String(digit))
                digitCount += 1
            } else if character == "." {
                guard decimalSeparatorCount == .zero else {
                    return nil
                }
                asciiText.append(character)
                decimalSeparatorCount += 1
            } else if character == "+" || character == "-" {
                guard index == .zero else {
                    return nil
                }
                asciiText.append(character)
            } else {
                return nil
            }
        }

        return digitCount > .zero ? asciiText : nil
    }
}

public extension String {
    /// True when the string is empty or can be parsed as a decimal.
    var isEmptyOrDecimal: Bool {
        if isEmpty {
            return true
        }
        return parsedDecimalValue != nil
    }

    /// Decimal value parsed from the string, or `.zero` when parsing fails.
    var decimalValue: Decimal {
        parsedDecimalValue ?? .zero
    }

    /// Parses a date using a fixed, locale-independent date format template.
    func dateValueWithoutLocale(_ template: DateFormatter.Template) -> Date? {
        DateFormatter.fixed(template).date(from: self)
    }
}

extension String {
    /// Decimal value parsed from the complete string, or `nil` when parsing fails.
    var parsedDecimalValue: Decimal? {
        parsedDecimalValue(locale: .current)
    }

    /// Decimal value parsed using the supplied user-facing locale.
    func parsedDecimalValue(
        locale: Locale
    ) -> Decimal? {
        DecimalTextParser.parse(
            self,
            locale: locale
        )
    }
}
