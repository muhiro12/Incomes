import Foundation

/// Builds deterministic instructions and prompts for item form inference.
public enum ItemFormInferencePromptBuilder {
    /// Builds the system instructions for item form inference.
    public static func instructions() -> String {
        """
        You are a professional financial advisor for a household accounting and budgeting app.
        Carefully extract and output the necessary fields from user input as an expert accountant.
        Always provide reliable and precise results.
        """
    }

    /// Builds the user prompt for item form inference.
    public static func prompt(
        text: String,
        currentDate: Date,
        locale: Locale
    ) -> String {
        let today = currentDateText(from: currentDate)
        let languageCode = languageCode(for: locale)

        return """
            Today's date is: \(today)
            You are a professional financial advisor for a household accounting and budgeting app.
            Carefully extract and output the following fields from the user input:
            - date (yyyyMMdd)
              If the date in the text is relative, such as 'last month' or 'next month',
              convert it to the correct date.
            - content (description)
            - income
            - outgo
            - category

            REQUIREMENT:
            - Respond ONLY with the values in the language: \(languageCode).
            - Never reply in English unless the device language is English.
            - All field values must be in the device's language, matching the user's input language.
            - If the language is Japanese, return all labels and values in Japanese,
              and treat relative time expressions (like '来月', '先月') accurately.
            - Output only the result values, no explanation, format, or extra words.

            User input JSON string: \(PromptLiteralSupport.jsonStringLiteral(text))
            """
    }

    /// Returns the language code used for inference prompts.
    public static func languageCode(for locale: Locale) -> String {
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
