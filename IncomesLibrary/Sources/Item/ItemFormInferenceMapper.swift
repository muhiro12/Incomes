import Foundation

public struct ItemFormInferenceUpdate {
    public let date: Date?
    public let content: String
    public let incomeText: String
    public let outgoText: String
    public let category: String

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
}

public enum ItemFormInferenceMapper {
    public static func map(
        dateString: String,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String
    ) -> ItemFormInferenceUpdate {
        let date = dateString.stableDateValueWithoutLocale(.yyyyMMdd)
        return .init(
            date: date,
            content: content,
            incomeText: income.description,
            outgoText: outgo.description,
            category: category
        )
    }
}
