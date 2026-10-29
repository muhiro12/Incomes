import Foundation

/// Shared item form inference prompt operations.
public enum ItemFormInferenceOperations {
    private static let generatedDateLength = 8

    /// Rejects unusable generated values before an app or Intent consumes them.
    @available(iOS 26.0, *)
    public static func validate(
        dateString: String,
        content: String,
        income: Decimal?,
        outgo: Decimal?
    ) throws {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ItemInferenceError.invalidResult
        }
        if !dateString.isEmpty, inferredDate(from: dateString) == nil {
            throw ItemInferenceError.invalidResult
        }
        if income == nil, outgo == nil {
            return
        }
        guard let income, let outgo,
              AmountPrecision.isExactlyStorable(income),
              AmountPrecision.isExactlyStorable(outgo),
              income >= .zero, outgo >= .zero,
              income == .zero || outgo == .zero else {
            throw ItemInferenceError.invalidResult
        }
    }

    /// Reads a generated local day without Foundation's default date for empty input.
    static func inferredDate(from dateString: String) -> Date? {
        let formatter = DateFormatter.fixed(.yyyyMMdd)
        formatter.calendar = .init(identifier: .gregorian)
        formatter.isLenient = false
        guard dateString.utf8.count == generatedDateLength,
              dateString.allSatisfy({ $0.isASCII && $0.isNumber }),
              let date = formatter.date(from: dateString),
              formatter.string(from: date) == dateString else {
            return nil
        }
        return date
    }

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
