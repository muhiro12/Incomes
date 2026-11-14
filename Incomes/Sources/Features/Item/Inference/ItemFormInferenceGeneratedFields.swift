import Foundation
import FoundationModels

@available(iOS 26.0, *)
@Generable(description: "Fields copied or inferred from one household finance item in source text.")
struct ItemFormInferenceGeneratedFields: Sendable {
    @Generable
    enum Direction {
        case income
        case outgo
        case unspecified
    }

    @Guide(description: """
    Copy only the transaction date words exactly, such as 昨日 or October 28, 2026. \
    Prefer the payment date over an invoice or due date. Empty if absent.
    """)
    var dateExpression: String
    @Guide(description: """
    income for money RECEIVED, including salary, refunds and rent collected from a tenant. \
    outgo for money PAID or a purchase receipt. \
    unspecified if the source says it is unknown whether money was paid or received, even when an amount is given.
    """)
    var direction: Direction
    @Guide(description: """
    Copy one complete amount number verbatim, preserving every digit and separator but no currency. \
    For a receipt use the final total, not a product price, cash tendered, change, tax or points. \
    Empty if no amount is given. Copy explicit zero as 0; never invent zero.
    """)
    var amountExpression: String
    @Guide(description: "Copy an explicit category verbatim, or suggest a concise category in the requested language.")
    var category: String
    @Guide(description: """
    The item's name and notes only. In a labelled record, stop before income/expense fields; \
    never include date, income, expense, category or currency fields in content. \
    Copy all description lines verbatim with their newlines. Otherwise describe the transaction briefly.
    """)
    var content: String
}
