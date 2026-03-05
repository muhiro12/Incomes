/// Suggested source/target year selection for yearly duplication UI.
public struct YearlyItemDuplicationSelectionState: Sendable {
    /// Source year.
    public let sourceYear: Int
    /// Target year.
    public let targetYear: Int

    /// Creates a selection state.
    public init(sourceYear: Int, targetYear: Int) {
        self.sourceYear = sourceYear
        self.targetYear = targetYear
    }
}
