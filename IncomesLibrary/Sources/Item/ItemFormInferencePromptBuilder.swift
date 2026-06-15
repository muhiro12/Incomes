import Foundation

/// Builds deterministic instructions and prompts for item form inference.
enum ItemFormInferencePromptBuilder {
    /// Builds the system instructions for item form inference.
    static func instructions() -> String {
        FoundationModelPromptTemplate(
            resourceName: "item-form-inference-instructions"
        )
        .render()
    }

    /// Builds the user prompt for item form inference.
    static func prompt(
        text: String,
        currentDate: Date,
        locale: Locale
    ) -> String {
        let today = currentDateText(from: currentDate)
        let languageCode = languageCode(for: locale)

        return FoundationModelPromptTemplate(
            resourceName: "item-form-inference-user-prompt"
        )
        .render(
            replacements: [
                "currentDate": today,
                "languageCode": languageCode,
                "localeIdentifier": locale.identifier,
                "userInputJSONString": PromptLiteralSupport.jsonStringLiteral(text)
            ]
        )
    }

    /// Returns the language code used for inference prompts.
    static func languageCode(for locale: Locale) -> String {
        LocaleLanguageCodeSupport.code(for: locale)
    }
}

private extension ItemFormInferencePromptBuilder {
    static func currentDateText(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = .init(identifier: .gregorian)
        formatter.locale = .init(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: date)
    }
}
