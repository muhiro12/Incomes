import AppIntents
import Foundation

enum ItemIntentCurrencyValidator {
    static func disambiguationAmount(
        amount: IntentCurrencyAmount,
        expectedCurrencyCode: String
    ) -> IntentCurrencyAmount? {
        guard amount.currencyCode != expectedCurrencyCode else {
            return nil
        }
        return .init(
            amount: amount.amount,
            currencyCode: expectedCurrencyCode
        )
    }
}
