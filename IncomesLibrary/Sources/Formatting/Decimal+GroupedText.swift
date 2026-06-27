import Foundation

private enum DecimalGroupedTextFormatter {
    private static let decimalComponentCount = 2
    private static let maximumDecimalComponentCount = 2

    static func groupedDecimalText(
        from text: String,
        locale: Locale
    ) -> String {
        groupedText(
            from: text,
            sourceDecimalSeparator: ".",
            locale: locale
        ) ?? text
    }

    static func groupedInputText(
        from text: String,
        locale: Locale
    ) -> String {
        let decimalSeparator = locale.decimalSeparator ?? "."
        return groupedText(
            from: text,
            sourceDecimalSeparator: decimalSeparator,
            locale: locale
        ) ?? text
    }
}

private extension DecimalGroupedTextFormatter {
    static func groupedText(
        from text: String,
        sourceDecimalSeparator: String,
        locale: Locale
    ) -> String? {
        guard !text.isEmpty else {
            return text
        }

        let components = text.components(separatedBy: sourceDecimalSeparator)
        guard components.count <= maximumDecimalComponentCount else {
            return nil
        }

        let groupedIntegerText = groupedIntegerComponent(
            components[0],
            locale: locale
        )
        guard let groupedIntegerText else {
            return nil
        }

        guard components.count == Self.decimalComponentCount else {
            return groupedIntegerText
        }

        let fractionalText = components[1]
        guard isValidFractionalComponent(fractionalText) else {
            return nil
        }

        let outputDecimalSeparator = locale.decimalSeparator ?? "."
        return groupedIntegerText + outputDecimalSeparator + fractionalText
    }

    static func groupedIntegerComponent(
        _ text: String,
        locale: Locale
    ) -> String? {
        let signText = signPrefix(in: text)
        let unsignedText = signText.isEmpty ? text : String(text.dropFirst())
        guard !unsignedText.isEmpty else {
            return signText
        }

        let groupingSeparator = locale.groupingSeparator ?? ","
        let integerText = unsignedText.replacingOccurrences(
            of: groupingSeparator,
            with: ""
        )
        guard integerText.allSatisfy(\.isNumber) else {
            return nil
        }

        let posixLocale = Locale(identifier: "en_US_POSIX")
        guard let integerValue = Decimal(string: integerText, locale: posixLocale) else {
            return nil
        }

        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        guard let groupedText = formatter.string(for: integerValue) else {
            return nil
        }
        return signText + groupedText
    }

    static func signPrefix(in text: String) -> String {
        guard let firstCharacter = text.first,
              firstCharacter == "-" || firstCharacter == "+" else {
            return ""
        }
        return String(firstCharacter)
    }

    static func isValidFractionalComponent(_ text: String) -> Bool {
        text.allSatisfy(\.isNumber)
    }
}

public extension Decimal {
    /// Formats the decimal with locale-aware grouping while preserving fractional digits.
    func groupedDecimalText(locale: Locale = .current) -> String {
        DecimalGroupedTextFormatter.groupedDecimalText(
            from: description,
            locale: locale
        )
    }
}

public extension String {
    /// Returns amount input text with grouped whole digits when it can be formatted safely.
    func groupedDecimalInputText(locale: Locale = .current) -> String {
        DecimalGroupedTextFormatter.groupedInputText(
            from: self,
            locale: locale
        )
    }
}
