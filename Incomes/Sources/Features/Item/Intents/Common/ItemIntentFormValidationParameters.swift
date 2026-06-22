import AppIntents

struct ItemIntentFormValidationParameters {
    let content: IntentParameter<String>
    let income: IntentParameter<IntentCurrencyAmount>
    let outgo: IntentParameter<IntentCurrencyAmount>
    let priority: IntentParameter<Int>?

    init(
        content: IntentParameter<String>,
        income: IntentParameter<IntentCurrencyAmount>,
        outgo: IntentParameter<IntentCurrencyAmount>,
        priority: IntentParameter<Int>? = nil
    ) {
        self.content = content
        self.income = income
        self.outgo = outgo
        self.priority = priority
    }
}
