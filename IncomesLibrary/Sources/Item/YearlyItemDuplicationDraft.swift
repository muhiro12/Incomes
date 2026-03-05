import Foundation

/// Domain draft used to prefill yearly duplication edits.
public struct YearlyItemDuplicationDraft: Sendable {
    /// Group identifier.
    public let groupID: UUID
    /// Base date used for the form.
    public let date: Date
    /// Suggested content.
    public let content: String
    /// Suggested income text.
    public let incomeText: String
    /// Suggested outgo text.
    public let outgoText: String
    /// Suggested category.
    public let category: String
    /// Suggested priority text.
    public let priorityText: String
    /// Suggested repeat month selections.
    public let repeatMonthSelections: Set<RepeatMonthSelection>

    /// Creates a draft.
    public init(
        groupID: UUID,
        date: Date,
        content: String,
        incomeText: String,
        outgoText: String,
        category: String,
        priorityText: String,
        repeatMonthSelections: Set<RepeatMonthSelection>
    ) {
        self.groupID = groupID
        self.date = date
        self.content = content
        self.incomeText = incomeText
        self.outgoText = outgoText
        self.category = category
        self.priorityText = priorityText
        self.repeatMonthSelections = repeatMonthSelections
    }
}
