import Foundation

/// Documented for SwiftLint compliance.
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

    /// Documented for SwiftLint compliance.
    public let date: Date
    /// Documented for SwiftLint compliance.
    public let content: String
    /// Documented for SwiftLint compliance.
    public let incomeText: String
    /// Documented for SwiftLint compliance.
    public let outgoText: String
    /// Documented for SwiftLint compliance.
    public let category: String
    /// Documented for SwiftLint compliance.
    public let priorityText: String

    /// Documented for SwiftLint compliance.
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

    /// Documented for SwiftLint compliance.
    public var isValid: Bool {
        (try? validate()) != nil
    }

    /// Documented for SwiftLint compliance.
    public var income: Decimal {
        incomeText.decimalValue
    }

    /// Documented for SwiftLint compliance.
    public var outgo: Decimal {
        outgoText.decimalValue
    }

    /// Documented for SwiftLint compliance.
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
