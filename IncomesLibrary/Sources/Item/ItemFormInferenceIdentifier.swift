import Foundation

/// Builds stable identifiers for generated item form inference values.
public enum ItemFormInferenceIdentifier {
    /// Builds an identifier from all generated item form inference fields.
    public static func make(
        date: String,
        content: String,
        income: Decimal,
        outgo: Decimal,
        category: String
    ) -> String {
        [
            date,
            content,
            income.description,
            outgo.description,
            category
        ]
        .map(component)
        .joined()
    }
}

private extension ItemFormInferenceIdentifier {
    static func component(_ value: String) -> String {
        "\(value.count):\(value)"
    }
}
