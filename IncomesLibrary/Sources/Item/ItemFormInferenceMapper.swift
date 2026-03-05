import Foundation

/// Documented for SwiftLint compliance.
public enum ItemFormInferenceMapper {
    /// Documented for SwiftLint compliance.
    public static func map(
        dateString: String,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String
    ) -> ItemFormInferenceUpdate {
        let date = dateString.dateValueWithoutLocale(.yyyyMMdd)
        return .init(
            date: date,
            content: content,
            incomeText: income.description,
            outgoText: outgo.description,
            category: category
        )
    }
}
