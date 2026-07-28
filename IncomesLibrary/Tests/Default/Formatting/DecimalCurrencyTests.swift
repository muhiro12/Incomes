import Foundation
@testable import IncomesLibrary
import Testing

struct DecimalCurrencyTests {
    @Test
    func currency_text_uses_requested_locale() throws {
        let value = Decimal(1_234.5)

        let englishText = try #require(
            DecimalCurrencyFormatter.currencyText(
                for: value,
                currencyCode: "USD",
                locale: Locale(identifier: "en_US")
            )
        )
        let germanText = try #require(
            DecimalCurrencyFormatter.currencyText(
                for: value,
                currencyCode: "USD",
                locale: Locale(identifier: "de_DE")
            )
        )

        #expect(englishText.contains("1,234.50"))
        #expect(germanText.contains("1.234,50"))
    }

    @Test
    func minus_currency_text_preserves_zero_and_negative_prefix() {
        let locale = Locale(identifier: "en_US")

        #expect(Decimal.zero.minusCurrencyText(locale: locale).hasPrefix("-") == false)
        #expect(Decimal(42).minusCurrencyText(locale: locale).hasPrefix("-"))
    }
}
