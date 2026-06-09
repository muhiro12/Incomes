import AppIntents

enum ItemIntentFormInputSupport {
    static func repeatMonthSelections(from value: String) throws -> Set<RepeatMonthSelection> {
        do {
            return try RepeatMonthSelectionParser.parse(value)
        } catch RepeatMonthSelectionParser.ParserError.invalidToken {
            throw ItemError.invalidRepeatMonthSelections
        }
    }

    static func validate(
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
