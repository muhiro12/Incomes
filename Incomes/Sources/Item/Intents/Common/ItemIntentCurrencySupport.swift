import AppIntents
import Foundation
import MHPlatform

enum ItemIntentCurrencySupport {
    static func preferredCurrencyCode() -> String {
        MHPreferenceStore().string(
            for: \.currencyCode,
            default: ""
        )
    }

    static func amount(from amount: Decimal?) -> IntentCurrencyAmount? {
        guard let amount else {
            return nil
        }
        return .init(
            amount: amount,
            currencyCode: preferredCurrencyCode()
        )
    }

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
