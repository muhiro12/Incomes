import Foundation

/// Shared item form inference prompt operations.
public enum ItemFormInferenceOperations {
    /// Builds the system instructions for item form inference.
    public static func instructions() -> String {
        ItemFormInferencePromptBuilder.instructions()
    }

    /// Builds the user prompt for item form inference.
    public static func prompt(
        text: String,
        currentDate: Date,
        locale: Locale
    ) -> String {
        ItemFormInferencePromptBuilder.prompt(
            text: text,
            currentDate: currentDate,
            locale: locale
        )
    }

    /// Returns the language code used for inference prompts.
    public static func languageCode(for locale: Locale) -> String {
        ItemFormInferencePromptBuilder.languageCode(for: locale)
    }

    /// Returns a stable identifier for generated item form inference values.
    public static func stableIdentifier(
        date: String,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String
    ) -> String {
        ItemFormInferenceIdentifier.make(
            date: date,
            content: content,
            income: income,
            outgo: outgo,
            category: category
        )
    }
}
