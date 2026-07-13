import Foundation
@testable import IncomesLibrary
import Testing

struct DecimalCurrencyTests {
    @Test
    func minusCurrencyFormatsLegacyNegativeValuesFromTheirMagnitude() {
        let amount: Decimal = 125

        #expect((-amount).asMinusCurrency == amount.asMinusCurrency)
    }
}
