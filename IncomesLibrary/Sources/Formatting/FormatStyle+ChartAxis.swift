import Foundation

private enum ChartAxisAmountFormat {
    // Three digits keep intermediate ticks such as 1.25M distinct from 1.2M.
    static let significantDigits = 1...3
}

public extension FormatStyle where Self == Decimal.FormatStyle {
    /// Formats chart axis amounts as compact, locale-aware numbers.
    ///
    /// Axis ticks need short labels, so large magnitudes use the locale's own
    /// compact units, such as `100万` or `1M`, instead of exponent notation
    /// such as `1.0E6`. The currency symbol is omitted because the chart
    /// context already establishes that the axis shows money.
    static func chartAxisAmount(locale: Locale) -> Self {
        Decimal.FormatStyle(locale: locale)
            .notation(.compactName)
            .precision(.significantDigits(ChartAxisAmountFormat.significantDigits))
    }
}
