import AppIntents
import Foundation

enum ItemIntentFormInputSupport {
    static func formInput(
        date: Date,
        content: String,
        income: IntentCurrencyAmount,
        outgo: IntentCurrencyAmount,
        category: String,
        priority: Int? = nil
    ) -> ItemFormInput {
        if let priority {
            return .init(
                date: date,
                content: content,
                income: income.amount,
                outgo: outgo.amount,
                category: category,
                priority: priority
            )
        }
        return .init(
            date: date,
            content: content,
            income: income.amount,
            outgo: outgo.amount,
            category: category
        )
    }

    static func repeatMonthSelections(from value: String) throws -> Set<RepeatMonthSelection> {
        do {
            return try RepeatMonthSelectionParser.parse(value)
        } catch RepeatMonthSelectionParser.ParserError.invalidToken {
            throw ItemError.invalidRepeatMonthSelections
        }
    }

    static func validate(
        formInput: ItemFormInput,
        income: IntentCurrencyAmount,
        outgo: IntentCurrencyAmount,
        parameters: ItemIntentFormValidationParameters
    ) throws {
        try validate(
            formInput: formInput,
            contentParameter: parameters.content,
            priorityParameter: parameters.priority
        )
        try ItemIntentCurrencySupport.validate(
            income: income,
            incomeParameter: parameters.income,
            outgo: outgo,
            outgoParameter: parameters.outgo
        )
    }

    private static func validate(
        formInput: ItemFormInput,
        contentParameter: IntentParameter<String>,
        priorityParameter: IntentParameter<Int>? = nil
    ) throws {
        do {
            try formInput.validate()
        } catch ItemFormInput.ValidationError.contentIsEmpty {
            throw contentParameter.needsValueError()
        } catch ItemFormInput.ValidationError.invalidPriority {
            guard let priorityParameter else {
                throw ItemFormInput.ValidationError.invalidPriority
            }
            throw priorityParameter.needsValueError()
        } catch {
            throw error
        }
    }
}
