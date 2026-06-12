import Foundation // swiftlint:disable:this file_name

public extension String {
    /// True when the string is blank or can be parsed as a decimal.
    var isEmptyOrDecimal: Bool {
        if isEmpty {
            return true
        }
        return Decimal(string: self) != nil
    }

    /// Decimal value parsed from the string, or `.zero` when parsing fails.
    var decimalValue: Decimal {
        Decimal(string: self) ?? .zero
    }

    /// Parses a date using a fixed, locale-independent date format template.
    func dateValueWithoutLocale(_ template: DateFormatter.Template) -> Date? {
        DateFormatter.fixed(template).date(from: self)
    }
}
