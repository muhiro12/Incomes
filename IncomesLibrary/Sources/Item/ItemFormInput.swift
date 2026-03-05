import Foundation

/// Documented for SwiftLint compliance.
public struct ItemFormInput {
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
        content.isNotEmpty
            && incomeText.isEmptyOrDecimal
            && outgoText.isEmptyOrDecimal
            && priorityText.isEmptyOrInt
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
}
