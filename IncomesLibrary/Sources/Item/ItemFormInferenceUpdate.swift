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
    /// True when the source did not provide an amount; zero remains an editable draft value.
    public let hasUnspecifiedAmount: Bool
    private let amountLocale: Locale?

    /// True when the current form date must be reviewed because no exact source day was read.
    public var hasUnspecifiedDate: Bool {
        date == nil
    }

    /// Creates an inferred item form update.
    init(
        date: Date?,
        content: String,
        incomeText: String,
        outgoText: String,
        category: String,
        hasUnspecifiedAmount: Bool = false,
        locale: Locale? = nil
    ) {
        self.date = date
        self.content = content
        self.incomeText = incomeText
        self.outgoText = outgoText
        self.category = category
        self.hasUnspecifiedAmount = hasUnspecifiedAmount
        amountLocale = locale
    }

    /// Creates an inferred item form update from typed amount values.
    public init(
        date: Date?,
        content: String,
        income: Decimal?,
        outgo: Decimal?,
        category: String,
        locale: Locale = .current
    ) {
        self.init(
            date: date,
            content: content,
            incomeText: (income ?? .zero).groupedDecimalText(locale: locale),
            outgoText: (outgo ?? .zero).groupedDecimalText(locale: locale),
            category: category,
            hasUnspecifiedAmount: income == nil && outgo == nil,
            locale: locale
        )
    }

    /// Creates an inferred item form update from generated date text and typed amount values.
    public init(
        dateString: String,
        content: String,
        income: Decimal?,
        outgo: Decimal?,
        category: String,
        locale: Locale = .current
    ) {
        self.init(
            date: ItemFormInferenceOperations.inferredDate(from: dateString),
            content: content,
            income: income,
            outgo: outgo,
            category: category,
            locale: locale
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
            priorityText: currentInput.priorityText,
            ledgerIdentifier: currentInput.ledgerIdentifier,
            locale: amountLocale
        )
    }
}
