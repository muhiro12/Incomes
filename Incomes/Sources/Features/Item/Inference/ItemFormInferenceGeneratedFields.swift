import Foundation
import FoundationModels

@available(iOS 26.0, *)
@Generable(description: "Fields copied or inferred from one household finance item in source text.")
struct ItemFormInferenceGeneratedFields: Sendable {
    @Guide(description: """
    Copy the date expression exactly from the source, such as 昨日 or October 28, 2026. \
    Empty if absent.
    """)
    var dateExpression: String
    @Guide(description: "A short item description in the requested language.")
    var content: String
    @Guide(description: "True only when no amount is given or the amount is undecided. False for an explicit zero.")
    var hasUnspecifiedAmount: Bool
    @Guide(description: """
    Money received, such as salary or sales. \
    Zero when paying or spending money, or when unspecified.
    """)
    var income: Decimal
    @Guide(description: """
    Money paid or spent, such as purchases or rent. \
    Zero when receiving money, or when unspecified.
    """)
    var outgo: Decimal
    @Guide(description: "A concise category name in the requested language.")
    var category: String
}
