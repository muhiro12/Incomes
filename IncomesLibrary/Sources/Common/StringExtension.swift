import Foundation // swiftlint:disable:this file_name

private enum DecimalTextParser {
    private static var parsingLocales: [Locale] {
        let fixedGroupingLocale = Locale(identifier: "en_US")
        let currentLocale = Locale.current

        guard currentLocale.identifier != fixedGroupingLocale.identifier else {
            return [fixedGroupingLocale]
        }

        return [fixedGroupingLocale, currentLocale]
    }

    static func parse(_ text: String) -> Decimal? {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedText.isEmpty else {
            return nil
        }

        for locale in parsingLocales {
            if let decimal = parse(trimmedText, locale: locale) {
                return decimal
            }
        }

        return nil
    }

    private static func parse(_ text: String, locale: Locale) -> Decimal? {
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

        return parsedObject as? Decimal
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
        DecimalTextParser.parse(self)
    }
}
