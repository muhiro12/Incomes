import Foundation

/// Documented for SwiftLint compliance.
public struct YearlyItemDuplicationSuggestion {
    /// Documented for SwiftLint compliance.
    public let sourceYear: Int
    /// Documented for SwiftLint compliance.
    public let targetYear: Int
    /// Documented for SwiftLint compliance.
    public let plan: YearlyItemDuplicationPlan

    /// Documented for SwiftLint compliance.
    public init(
        sourceYear: Int,
        targetYear: Int,
        plan: YearlyItemDuplicationPlan
    ) {
        self.sourceYear = sourceYear
        self.targetYear = targetYear
        self.plan = plan
    }
}
