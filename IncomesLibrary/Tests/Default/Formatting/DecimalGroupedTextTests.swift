import Foundation
@testable import IncomesLibrary
import Testing

struct DecimalGroupedTextTests {
    @Test
    func groupedDecimalText_groups_integer_digits() {
        let text = (Decimal(string: "1234567") ?? .zero).groupedDecimalText(
            locale: Locale(identifier: "en_US")
        )

        #expect(text == "1,234,567")
    }

    @Test
    func groupedDecimalText_preserves_fractional_digits() {
        let text = (Decimal(string: "1234567.1234567890123456789") ?? .zero)
            .groupedDecimalText(locale: Locale(identifier: "en_US"))

        #expect(text == "1,234,567.1234567890123456789")
    }

    @Test
    func groupedDecimalText_preserves_negative_sign() {
        let text = (Decimal(string: "-1234567.5") ?? .zero).groupedDecimalText(
            locale: Locale(identifier: "en_US")
        )

        #expect(text == "-1,234,567.5")
    }

    @Test
    func groupedDecimalInputText_groups_integer_digits() {
        let text = "1234567".groupedDecimalInputText(
            locale: Locale(identifier: "en_US")
        )

        #expect(text == "1,234,567")
    }

    @Test
    func groupedDecimalInputText_preserves_trailing_decimal_separator() {
        let text = "1234567.".groupedDecimalInputText(
            locale: Locale(identifier: "en_US")
        )

        #expect(text == "1,234,567.")
    }

    @Test
    func groupedDecimalInputText_preserves_fractional_text() {
        let text = "1234567.00".groupedDecimalInputText(
            locale: Locale(identifier: "en_US")
        )

        #expect(text == "1,234,567.00")
    }

    @Test
    func groupedDecimalInputText_normalizes_existing_grouping() {
        let text = "1234,567".groupedDecimalInputText(
            locale: Locale(identifier: "en_US")
        )

        #expect(text == "1,234,567")
    }

    @Test
    func groupedDecimalInputText_preserves_invalid_text() {
        let text = "1234abc".groupedDecimalInputText(
            locale: Locale(identifier: "en_US")
        )

        #expect(text == "1234abc")
    }
}
