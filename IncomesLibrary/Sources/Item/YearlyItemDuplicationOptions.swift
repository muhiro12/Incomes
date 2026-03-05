import Foundation

/// Documented for SwiftLint compliance.
public struct YearlyItemDuplicationOptions {
    /// Documented for SwiftLint compliance.
    public let includeSingleItems: Bool
    /// Documented for SwiftLint compliance.
    public let minimumRepeatItemCount: Int
    /// Documented for SwiftLint compliance.
    public let skipExistingItems: Bool

    /// Documented for SwiftLint compliance.
    public init(
        includeSingleItems: Bool = false,
        minimumRepeatItemCount: Int = 3,
        skipExistingItems: Bool = true
    ) {
        self.includeSingleItems = includeSingleItems
        self.minimumRepeatItemCount = minimumRepeatItemCount
        self.skipExistingItems = skipExistingItems
    }
}
