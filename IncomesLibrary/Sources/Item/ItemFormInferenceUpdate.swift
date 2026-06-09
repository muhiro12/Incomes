import Foundation

/// Suggested item form values inferred from another input source.
public struct ItemFormInferenceUpdate {
    /// Suggested local date, if one was inferred.
    public let date: Date?
    /// Suggested item description text.
    public let content: String
    /// Suggested income amount represented as text.
    public let incomeText: String
    /// Suggested outgo amount represented as text.
    public let outgoText: String
    /// Suggested category name.
    public let category: String

    /// Creates an inferred item form update.
    public init(
        date: Date?,
        content: String,
        incomeText: String,
        outgoText: String,
        category: String
    ) {
        self.date = date
        self.content = content
        self.incomeText = incomeText
        self.outgoText = outgoText
        self.category = category
    }

    /// Creates an inferred item form update from typed amount values.
    public init(
        date: Date?,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String
    ) {
        self.init(
            date: date,
            content: content,
            incomeText: income.description,
            outgoText: outgo.description,
            category: category
        )
    }

    /// Creates an inferred item form update from generated date text and typed amount values.
    public init(
        dateString: String,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String
    ) {
        self.init(
            date: dateString.dateValueWithoutLocale(.yyyyMMdd),
            content: content,
            income: income,
            outgo: outgo,
            category: category
        )
    }

    /// Applies the inferred values to the current form input.
    public func applied(to currentInput: ItemFormInput) -> ItemFormInput {
        .init(
            date: date ?? currentInput.date,
            content: content,
            incomeText: incomeText,
            outgoText: outgoText,
            category: category,
            priorityText: currentInput.priorityText
        )
    }
}
