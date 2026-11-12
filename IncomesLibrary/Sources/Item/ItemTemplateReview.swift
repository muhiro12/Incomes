import Foundation

/// A parsed proposal bound to the source, original draft, and reviewed currency.
public struct ItemTemplateReview: Equatable {
    /// Proposed values; applying these does not save an Item.
    public let input: ItemFormInput
    private let originalInput: ItemFormInput
    private let sourceText: String
    private let currencyCode: String

    /// Captures the inputs that must remain unchanged before applying a proposal.
    public init(input: ItemFormInput, originalInput: ItemFormInput, sourceText: String, currencyCode: String) {
        self.input = input
        self.originalInput = originalInput
        self.sourceText = sourceText
        self.currencyCode = currencyCode
    }

    /// Rejects a proposal after the source, form, destination ledger, or currency changes.
    public func isCurrent(input: ItemFormInput, sourceText: String, currencyCode: String) -> Bool {
        originalInput == input && self.sourceText == sourceText && self.currencyCode == currencyCode
    }
}
