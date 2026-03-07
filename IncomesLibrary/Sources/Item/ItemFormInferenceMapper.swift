import Foundation

/// Maps normalized inference values into `ItemFormInferenceUpdate`.
public enum ItemFormInferenceMapper {
    /// Builds an inference update from parsed form values.
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
