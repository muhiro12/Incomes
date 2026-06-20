import Foundation

/// Stored item values after form-level normalization has already been applied.
public struct ItemStoredValues {
    /// Local calendar date selected for the item.
    public let date: Date
    /// User-entered item description.
    public let content: String
    /// Income amount assigned to the item.
    public let income: Decimal
    /// Outgo amount assigned to the item.
    public let outgo: Decimal
    /// Stored category name, not a localized display label.
    public let category: String
    /// Display priority used when multiple items share the same day.
    public let priority: Int

    /// Creates stored item values.
    public init(
        date: Date,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String,
        priority: Int
    ) {
        self.date = date
        self.content = content
        self.income = income
        self.outgo = outgo
        self.category = category
        self.priority = priority
    }
}

public extension ItemStoredValues {
    /// Creates stored values from validated form input.
    init(formInput: ItemFormInput) {
        self.init(
            date: formInput.date,
            content: formInput.content,
            income: formInput.income,
            outgo: formInput.outgo,
            category: formInput.storedCategory,
            priority: formInput.priority
        )
    }

    /// Returns a copy using a different date.
    func replacing(date: Date) -> Self {
        .init(
            date: date,
            content: content,
            income: income,
            outgo: outgo,
            category: category,
            priority: priority
        )
    }
}
