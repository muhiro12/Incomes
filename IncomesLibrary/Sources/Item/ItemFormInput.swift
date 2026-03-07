import Foundation

/// Normalized date and text inputs for creating or updating an item.
public struct ItemFormInput {
    /// Validation errors for item form values.
    public enum ValidationError: Error, Equatable {
        /// Content is required.
        case contentIsEmpty
        /// Income text is not a valid decimal.
        case invalidIncome
        /// Outgo text is not a valid decimal.
        case invalidOutgo
        /// Priority text is not a valid integer.
        case invalidPriority
    }

    /// Selected local date for the item.
    public let date: Date
    /// Item description text.
    public let content: String
    /// Income amount entered as text.
    public let incomeText: String
    /// Outgo amount entered as text.
    public let outgoText: String
    /// Category name entered for the item.
    public let category: String
    /// Priority value entered as text.
    public let priorityText: String

    /// Creates an item form input snapshot.
    public init( // swiftlint:disable:this type_contents_order
        date: Date,
        content: String,
        incomeText: String,
        outgoText: String,
        category: String,
        priorityText: String
    ) {
        self.date = date
        self.content = content
        self.incomeText = incomeText
        self.outgoText = outgoText
        self.category = category
        self.priorityText = priorityText
    }

    /// True when all form values pass `validate()`.
    public var isValid: Bool {
        (try? validate()) != nil
    }

    /// Income value parsed from `incomeText`.
    public var income: Decimal {
        incomeText.decimalValue
    }

    /// Outgo value parsed from `outgoText`.
    public var outgo: Decimal {
        outgoText.decimalValue
    }

    /// Priority value parsed from `priorityText`.
    public var priority: Int {
        priorityText.intValue
    }

    /// Validates form values and throws a specific validation error.
    public func validate() throws {
        guard content.isNotEmpty else {
            throw ValidationError.contentIsEmpty
        }
        guard incomeText.isEmptyOrDecimal else {
            throw ValidationError.invalidIncome
        }
        guard outgoText.isEmptyOrDecimal else {
            throw ValidationError.invalidOutgo
        }
        guard priorityText.isEmptyOrInt else {
            throw ValidationError.invalidPriority
        }
    }
}
