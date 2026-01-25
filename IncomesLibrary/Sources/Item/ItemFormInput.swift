import Foundation

public struct ItemFormInput {
    public let date: Date
    public let content: String
    public let incomeText: String
    public let outgoText: String
    public let category: String
    public let priorityText: String

    public init(
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

    public var isValid: Bool {
        content.isNotEmpty
            && incomeText.isEmptyOrDecimal
            && outgoText.isEmptyOrDecimal
            && priorityText.isEmptyOrInt
    }

    public var income: Decimal {
        incomeText.decimalValue
    }

    public var outgo: Decimal {
        outgoText.decimalValue
    }

    public var priority: Int {
        priorityText.intValue
    }
}
