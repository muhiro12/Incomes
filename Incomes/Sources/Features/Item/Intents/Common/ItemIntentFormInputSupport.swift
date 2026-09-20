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
            return try RepeatMonthSelectionOperations.parse(value)
        } catch RepeatMonthSelectionOperations.ParseError.invalidToken {
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
            parameters: parameters
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
        parameters: ItemIntentFormValidationParameters
    ) throws {
        do {
            try formInput.validate()
        } catch ItemFormInput.ValidationError.contentIsEmpty {
            throw parameters.content.needsValueError()
        } catch ItemFormInput.ValidationError.invalidIncome,
                ItemFormInput.ValidationError.unsupportedIncome {
            throw parameters.income.needsValueError()
        } catch ItemFormInput.ValidationError.invalidOutgo,
                ItemFormInput.ValidationError.unsupportedOutgo {
            throw parameters.outgo.needsValueError()
        } catch ItemFormInput.ValidationError.invalidPriority {
            guard let priorityParameter = parameters.priority else {
                throw ItemFormInput.ValidationError.invalidPriority
            }
            throw priorityParameter.needsValueError()
        } catch {
            throw error
        }
    }
}
