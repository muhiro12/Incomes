import Foundation

enum DecimalTextParser {
    private enum ParseResult {
        case value(Decimal)
        case rejected(DecimalTextRejection)
    }

    private static let decimalDigitValues = 0...9
    private static let posixLocale = Locale(identifier: "en_US_POSIX")

    private static var parsingLocales: [Locale] {
        let fixedGroupingLocale = Locale(identifier: "en_US")
        let currentLocale = Locale.current

        guard currentLocale.identifier != fixedGroupingLocale.identifier else {
            return [fixedGroupingLocale]
        }

        return [fixedGroupingLocale, currentLocale]
    }

    static func parse(_ text: String) -> Decimal? {
        switch result(for: text) {
        case .value(let decimal):
            return decimal
        case .rejected:
            return nil
        }
    }

    static func rejection(for text: String) -> DecimalTextRejection? {
        switch result(for: text) {
        case .value:
            return nil
        case .rejected(let rejection):
            return rejection
        }
    }

    /// Parses `text` using a single locale, for deterministic verification.
    static func parse(_ text: String, locale: Locale) -> Decimal? {
        switch result(for: text.trimmingCharacters(in: .whitespacesAndNewlines), locale: locale) {
        case .value(let decimal):
            return decimal
        case .rejected:
            return nil
        }
    }

    /// Returns the rejection reason for `text` in a single locale.
    static func rejection(for text: String, locale: Locale) -> DecimalTextRejection? {
        switch result(for: text.trimmingCharacters(in: .whitespacesAndNewlines), locale: locale) {
        case .value:
            return nil
        case .rejected(let rejection):
            return rejection
        }
    }

    private static func result(for text: String) -> ParseResult {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedText.isEmpty else {
            return .rejected(.notANumber)
        }

        var rejection = DecimalTextRejection.notANumber

        for locale in parsingLocales {
            switch result(for: trimmedText, locale: locale) {
            case .value(let decimal):
                return .value(decimal)
            case .rejected(.unsupportedAmount):
                rejection = .unsupportedAmount
            case .rejected(.notANumber):
                continue
            }
        }

        return .rejected(rejection)
    }

    private static func result(for text: String, locale: Locale) -> ParseResult {
        guard isNumberText(text, locale: locale),
              let plainText = plainNumberText(from: text, locale: locale) else {
            return .rejected(.notANumber)
        }
        // `Decimal(string:)` returns nil outside its exponent range, and the
        // store keeps fewer digits than `Decimal` itself, so an amount that
        // cannot be kept exactly is rejected instead of silently changed.
        let significand = plainText.prefix { character in
            character != "e" && character != "E"
        }
        guard AmountPrecision.significantDigitCount(in: String(significand))
                <= AmountPrecision.maximumSignificantDigits,
              let decimal = Decimal(string: plainText, locale: posixLocale),
              AmountPrecision.isExactlyStorable(decimal) else {
            return .rejected(.unsupportedAmount)
        }

        return .value(decimal)
    }

    /// True when `locale` reads the complete text as a number.
    private static func isNumberText(_ text: String, locale: Locale) -> Bool {
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
            return false
        }

        return parsedRange.location == .zero
            && parsedRange.length == text.utf16.count
    }

    /// Rewrites localized number text into a plain sign/digit/exponent form.
    private static func plainNumberText(from text: String, locale: Locale) -> String? {
        var separatedText = text

        for separator in groupingSeparators(for: locale) {
            separatedText = separatedText.replacingOccurrences(
                of: separator,
                with: ""
            )
        }

        let decimalSeparator = locale.decimalSeparator ?? "."
        if decimalSeparator != "." {
            separatedText = separatedText.replacingOccurrences(
                of: decimalSeparator,
                with: "."
            )
        }

        var plainText = ""

        for character in separatedText {
            if let digit = character.wholeNumberValue,
               character.isNumber,
               decimalDigitValues.contains(digit) {
                plainText.append(String(digit))
                continue
            }
            switch character {
            case ".",
                 "e",
                 "E",
                 "+",
                 "-":
                plainText.append(character)
            case "\u{2212}":
                plainText.append("-")
            default:
                return nil
            }
        }

        guard isPlainNumberText(plainText) else {
            return nil
        }

        return plainText
    }

    private static func groupingSeparators(for locale: Locale) -> [String] {
        var separators = ["\u{00A0}", "\u{202F}", "\u{2009}", " ", "'"]

        if let groupingSeparator = locale.groupingSeparator,
           !groupingSeparator.isEmpty,
           !separators.contains(groupingSeparator) {
            separators.append(groupingSeparator)
        }

        return separators.filter { separator in
            separator != locale.decimalSeparator
        }
    }

    /// True for `[+-]?digits[.digits][(e|E)[+-]?digits]`.
    private static func isPlainNumberText(_ text: String) -> Bool {
        var remaining = Substring(text)

        if remaining.first == "+" || remaining.first == "-" {
            remaining = remaining.dropFirst()
        }

        let integerDigits = remaining.prefix { character in
            character.isASCII && character.isNumber
        }
        remaining = remaining.dropFirst(integerDigits.count)

        var fractionDigits = Substring("")
        if remaining.first == "." {
            remaining = remaining.dropFirst()
            fractionDigits = remaining.prefix { character in
                character.isASCII && character.isNumber
            }
            remaining = remaining.dropFirst(fractionDigits.count)
        }

        guard !integerDigits.isEmpty || !fractionDigits.isEmpty else {
            return false
        }

        guard !remaining.isEmpty else {
            return true
        }

        guard remaining.first == "e" || remaining.first == "E" else {
            return false
        }
        remaining = remaining.dropFirst()

        if remaining.first == "+" || remaining.first == "-" {
            remaining = remaining.dropFirst()
        }

        let exponentDigits = remaining.prefix { character in
            character.isASCII && character.isNumber
        }

        return !exponentDigits.isEmpty
            && exponentDigits.count == remaining.count
    }
}

public extension String {
    /// True when the string is empty or can be stored exactly as a decimal.
    var isEmptyOrDecimal: Bool {
        if isEmpty {
            return true
        }
        return parsedDecimalValue != nil
    }

    /// Reason the string cannot be stored exactly, or `nil` when empty or valid.
    var decimalRejection: DecimalTextRejection? {
        if isEmpty {
            return nil
        }
        return DecimalTextParser.rejection(for: self)
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
