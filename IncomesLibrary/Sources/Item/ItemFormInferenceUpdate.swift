import Foundation

/// Documented for SwiftLint compliance.
public struct ItemFormInferenceUpdate {
    /// Documented for SwiftLint compliance.
    public let date: Date?
    /// Documented for SwiftLint compliance.
    public let content: String
    /// Documented for SwiftLint compliance.
    public let incomeText: String
    /// Documented for SwiftLint compliance.
    public let outgoText: String
    /// Documented for SwiftLint compliance.
    public let category: String

    /// Documented for SwiftLint compliance.
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
