import Foundation

/// Suggested item form values inferred from another input source.
public struct ItemFormInferenceUpdate {
    /// Suggested local date, if one was inferred.
    public let date: Date?
    /// Suggested item description text.
    public let content: String
    /// Suggested income amount represented as text.
    public let incomeText: String
    /// Suggested outgo amount represented as text.
    public let outgoText: String
    /// Suggested category name.
    public let category: String

    /// Creates an inferred item form update.
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
