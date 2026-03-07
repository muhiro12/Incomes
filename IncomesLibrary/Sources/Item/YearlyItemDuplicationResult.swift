import Foundation

/// Documented for SwiftLint compliance.
public struct YearlyItemDuplicationResult: Sendable {
    /// Documented for SwiftLint compliance.
    public let createdCount: Int
    /// Documented for SwiftLint compliance.
    public let skippedDuplicateCount: Int

    /// Documented for SwiftLint compliance.
    public init(createdCount: Int, skippedDuplicateCount: Int) {
        self.createdCount = createdCount
        self.skippedDuplicateCount = skippedDuplicateCount
    }
}
