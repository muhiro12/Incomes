import Foundation
@testable import IncomesLibrary
import Testing

struct DecimalTextParserTests {
    private let english = Locale(identifier: "en_US")
    private let supportedText = String(repeating: "9", count: AmountPrecision.maximumSignificantDigits)
    private let unsupportedText = String(repeating: "9", count: AmountPrecision.maximumSignificantDigits + 1)

    @Test("A value using the full supported precision keeps every entered digit")
    func supported_precision_keeps_every_digit() {
        #expect(DecimalTextParser.parse(supportedText, locale: english) == Decimal(string: supportedText))
    }

    @Test("A value beyond the supported precision is rejected, not rounded")
    func value_beyond_supported_precision_is_rejected() {
        #expect(DecimalTextParser.parse(unsupportedText, locale: english) == nil)
        #expect(DecimalTextParser.rejection(for: unsupportedText, locale: english) == .unsupportedAmount)
    }

    @Test("Digits lost by Decimal parsing are rejected before conversion")
    func parser_rounding_cannot_bypass_precision_validation() {
        let longInteger = "1" + String(repeating: "0", count: 60) + "1"
        let longFraction = "0.1" + String(repeating: "0", count: 60) + "1"
        for text in [longInteger, longFraction, "-" + longInteger, longInteger + "e-60"] {
            #expect(DecimalTextParser.parse(text, locale: english) == nil)
            #expect(DecimalTextParser.rejection(for: text, locale: english) == .unsupportedAmount)
        }
        #expect(DecimalTextParser.parse("1e60", locale: english) == Decimal(string: "1e60"))
        #expect(DecimalTextParser.parse("1.230000e2", locale: english) == Decimal(123))
    }

    @Test("A fraction beyond the supported precision is rejected, not rounded")
    func fraction_beyond_supported_precision_is_rejected() {
        let text = "0." + unsupportedText
        #expect(DecimalTextParser.rejection(for: text, locale: english) == .unsupportedAmount)
    }

    @Test("A value beyond the exponent range is rejected instead of stored as NaN")
    func value_beyond_exponent_range_is_rejected() {
        let text = "1" + String(repeating: "0", count: 200)
        #expect(DecimalTextParser.parse(text, locale: english) == nil)
        #expect(DecimalTextParser.rejection(for: text, locale: english) == .unsupportedAmount)
        #expect(!text.isEmptyOrDecimal)
        #expect(text.decimalRejection == .unsupportedAmount)
    }

    @Test("Trailing zeros do not consume supported precision")
    func trailing_zeros_do_not_consume_precision() {
        let text = "1" + String(repeating: "0", count: 60)
        #expect(DecimalTextParser.parse(text, locale: english) == Decimal(string: "1e60"))
    }

    @Test("Text that is not a number is reported separately from an unsupported amount")
    func text_is_reported_as_not_a_number() {
        #expect(DecimalTextParser.rejection(for: "text", locale: english) == .notANumber)
        #expect(DecimalTextParser.rejection(for: "1abc", locale: english) == .notANumber)
        #expect("text".decimalRejection == .notANumber)
        #expect("".decimalRejection == nil)
    }

    @Test("Negative and signed zero amounts stay supported")
    func negative_and_signed_zero_are_supported() {
        #expect(DecimalTextParser.parse("-1,234.56", locale: english) == Decimal(string: "-1234.56"))
        #expect(DecimalTextParser.parse("-0", locale: english) == .zero)
        #expect(DecimalTextParser.parse("-" + supportedText, locale: english) == Decimal(string: "-" + supportedText))
    }

    @Test(
        "Locale grouping and decimal separators parse to the same value",
        arguments: [
            ("en_US", "1,234.56"),
            ("de_DE", "1.234,56"),
            ("fr_FR", "1\u{202F}234,56"),
            ("ja_JP", "1,234.56"),
            ("es_ES", "1.234,56"),
            ("zh_Hans_CN", "1,234.56")
        ]
    )
    func locale_separators_parse_to_same_value(identifier: String, text: String) {
        let locale = Locale(identifier: identifier)
        #expect(DecimalTextParser.parse(text, locale: locale) == Decimal(string: "1234.56"))
    }

    @Test("Boundary neighbors on both sides of the supported precision behave consistently")
    func boundary_neighbors_behave_consistently() {
        let supported = "1" + String(repeating: "0", count: AmountPrecision.maximumSignificantDigits - 2) + "1"
        let unsupported = "1" + String(repeating: "0", count: AmountPrecision.maximumSignificantDigits - 1) + "1"
        #expect(DecimalTextParser.parse(supported, locale: english) == Decimal(string: supported))
        #expect(DecimalTextParser.rejection(for: unsupported, locale: english) == .unsupportedAmount)
    }

    @Test("A derived amount is rounded to the supported precision, never left unstorable")
    func derived_amount_is_rounded_to_supported_precision() throws {
        let repeating = try #require(Decimal(string: "301")) / 3
        let rounded = AmountPrecision.storableValue(repeating)
        #expect(!AmountPrecision.isExactlyStorable(repeating))
        #expect(AmountPrecision.isExactlyStorable(rounded))
        #expect(rounded == Decimal(string: "100.333333333333"))

        let exact = try #require(Decimal(string: "1234.56"))
        #expect(AmountPrecision.storableValue(exact) == exact)

        let largeDerived = try #require(Decimal(string: "12345678901234567890"))
        let roundedLarge = AmountPrecision.storableValue(largeDerived)
        #expect(AmountPrecision.isExactlyStorable(roundedLarge))
        #expect(roundedLarge == Decimal(string: "12345678901234600000"))
    }
}
