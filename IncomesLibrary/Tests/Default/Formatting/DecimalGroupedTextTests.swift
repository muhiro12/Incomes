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
}
