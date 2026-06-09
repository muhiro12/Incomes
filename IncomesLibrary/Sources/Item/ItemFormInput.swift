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

    /// Creates an item form input snapshot from a draft.
    public init(draft: ItemFormDraft) { // swiftlint:disable:this type_contents_order
        self.init(
            date: draft.date,
            content: draft.content,
            incomeText: draft.incomeText,
            outgoText: draft.outgoText,
            category: draft.category,
            priorityText: draft.priorityText.isEmpty ? "0" : draft.priorityText
        )
    }

    /// Creates an item form input snapshot from an existing item.
    public init(item: Item) { // swiftlint:disable:this type_contents_order
        self.init(
            date: item.localDate,
            content: item.content,
            incomeText: item.income.isNotZero ? item.income.description : .empty,
            outgoText: item.outgo.isNotZero ? item.outgo.description : .empty,
            category: CategoryNameSupport.displayName(
                forStoredName: item.category?.name
            ),
            priorityText: "\(item.priority)"
        )
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

    /// Category value normalized for persistence.
    public var storedCategory: String {
        CategoryNameSupport.normalizedStoredName(
            forUserInput: category
        )
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
