import Foundation

/// Amount precision the persistent store keeps without changing the value.
///
/// The limit comes from persistence evidence, not from `Decimal` capacity: a
/// value saved to a SwiftData store and read back after reopening keeps at most
/// `maximumSignificantDigits` significant digits, and longer values come back
/// rounded. Amounts are therefore rejected or explicitly rounded before they
/// reach the store instead of being changed silently by it.
public enum AmountPrecision {
    /// Significant digits verified to survive a store save and reopen unchanged.
    public static let maximumSignificantDigits = 15

    /// True when `value` is finite and keeps every digit through the store.
    public static func isExactlyStorable(_ value: Decimal) -> Bool {
        guard !value.isNaN else {
            return false
        }
        return significantDigitCount(in: value.description) <= maximumSignificantDigits
    }

    /// Returns a derived amount rounded to the stored precision.
    ///
    /// Use this for calculated values such as averages. Never use it to change
    /// an amount a person entered.
    public static func storableValue(_ value: Decimal) -> Decimal {
        guard !value.isNaN,
              !isExactlyStorable(value) else {
            return value
        }
        var source = value
        var rounded = Decimal.zero
        NSDecimalRound(
            &rounded,
            &source,
            storableScale(for: value),
            .plain
        )
        return rounded
    }

    /// Significant digits in a plain decimal representation.
    static func significantDigitCount(in plainText: String) -> Int {
        let digits = plainText.filter { character in
            character.isASCII && character.isNumber
        }
        let withoutLeadingZeros = digits.drop { character in
            character == "0"
        }
        let withoutTrailingZeros = withoutLeadingZeros.reversed().drop { character in
            character == "0"
        }
        return withoutTrailingZeros.count
    }
}

private extension AmountPrecision {
    /// Fraction-digit scale that keeps exactly the supported significant digits.
    static func storableScale(for value: Decimal) -> Int {
        maximumSignificantDigits - 1 - leadingDigitExponent(in: value.description)
    }

    /// Power of ten of the most significant digit, or zero for a zero value.
    static func leadingDigitExponent(in plainText: String) -> Int {
        let unsignedText = plainText.drop { character in
            character == "-" || character == "+"
        }
        let components = unsignedText.split(
            separator: ".",
            maxSplits: 1,
            omittingEmptySubsequences: false
        )
        let integerText = components.first ?? ""
        if let index = integerText.firstIndex(where: { character in
            character != "0"
        }) {
            return integerText.distance(from: index, to: integerText.endIndex) - 1
        }
        let fractionText = components.count > 1 ? components[1] : ""
        guard let index = fractionText.firstIndex(where: { character in
            character != "0"
        }) else {
            return .zero
        }
        return -(fractionText.distance(from: fractionText.startIndex, to: index) + 1)
    }
}
