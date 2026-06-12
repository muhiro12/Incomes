import AppIntents
import Foundation

enum ItemIntentCurrencySupport {
    static func amount(from amount: Decimal?) -> IntentCurrencyAmount? {
        guard let amount else {
            return nil
        }
        return .init(
            amount: amount,
            currencyCode: IncomesCurrencyPreference.preferredCurrencyCode()
        )
    }

    static func validate(
        income: IntentCurrencyAmount,
        incomeParameter: IntentParameter<IntentCurrencyAmount>,
        outgo: IntentCurrencyAmount,
        outgoParameter: IntentParameter<IntentCurrencyAmount>
    ) throws {
        let currencyCode = IncomesCurrencyPreference.preferredCurrencyCode()
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

    private static func disambiguationAmount(
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
