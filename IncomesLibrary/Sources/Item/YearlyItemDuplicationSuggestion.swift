import Foundation

/// Suggested source and target years with a prebuilt duplication plan.
public struct YearlyItemDuplicationSuggestion {
    /// Suggested source year.
    public let sourceYear: Int
    /// Suggested target year.
    public let targetYear: Int
    /// Precomputed plan for the suggested year pair.
    public let plan: YearlyItemDuplicationPlan

    /// Creates a yearly duplication suggestion.
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
