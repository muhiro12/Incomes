import Foundation

public extension Decimal {
    /// Formats the decimal with locale-aware grouping while preserving fractional digits.
    func groupedDecimalText(locale: Locale = .current) -> String {
        let text = description
        let isNegative = text.hasPrefix("-")
        let unsignedText = isNegative ? String(text.dropFirst()) : text
        let components = unsignedText.split(
            separator: ".",
            maxSplits: 1,
            omittingEmptySubsequences: false
        )

        guard let integerComponent = components.first else {
            return text
        }

        let integerText = Self.groupedIntegerText(
            String(integerComponent),
            locale: locale
        ) ?? String(integerComponent)
        let signText = isNegative ? "-" : ""
        guard components.count > 1 else {
            return signText + integerText
        }

        let decimalSeparator = locale.decimalSeparator ?? "."
        return signText + integerText + decimalSeparator + components[1]
    }
}

private extension Decimal {
    static func groupedIntegerText(
        _ integerText: String,
        locale: Locale
    ) -> String? {
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
        return formatter.string(for: integerValue)
    }
}
