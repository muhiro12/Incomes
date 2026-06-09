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

    static func validate(
        income: IntentCurrencyAmount,
        incomeParameter: IntentParameter<IntentCurrencyAmount>,
        outgo: IntentCurrencyAmount,
        outgoParameter: IntentParameter<IntentCurrencyAmount>
    ) throws {
        let currencyCode = preferredCurrencyCode()
        try validate(
            amount: income,
            parameter: incomeParameter,
            expectedCurrencyCode: currencyCode
        )
        try validate(
            amount: outgo,
            parameter: outgoParameter,
            expectedCurrencyCode: currencyCode
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

    private static func validate(
        amount: IntentCurrencyAmount,
        parameter: IntentParameter<IntentCurrencyAmount>,
        expectedCurrencyCode: String
    ) throws {
        if let amount = disambiguationAmount(
            amount: amount,
            expectedCurrencyCode: expectedCurrencyCode
        ) {
            throw parameter.needsDisambiguationError(among: [amount])
        }
    }
}
