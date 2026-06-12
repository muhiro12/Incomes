import Foundation

/// Draft values used to prefill the item form.
public struct ItemFormDraft: Identifiable, Hashable, Sendable {
    /// Stable presentation identifier.
    public let id: UUID
    /// Source group identifier for grouped draft flows.
    public let groupID: UUID
    /// Initial form date.
    public let date: Date
    /// Initial content text.
    public let content: String
    /// Initial income text.
    public let incomeText: String
    /// Initial outgo text.
    public let outgoText: String
    /// Initial category text.
    public let category: String
    /// Initial priority text.
    public let priorityText: String
    /// Initial repeat month selections.
    public let repeatMonthSelections: Set<RepeatMonthSelection>
    /// True when the draft represents more than the base month.
    public let isRepeatEnabled: Bool

    /// Creates an item form draft.
    public init(
        id: UUID = UUID(), // swiftlint:disable:this function_default_parameter_at_end
        groupID: UUID,
        date: Date,
        content: String,
        incomeText: String,
        outgoText: String,
        category: String,
        priorityText: String = "0", // swiftlint:disable:this function_default_parameter_at_end
        repeatMonthSelections: Set<RepeatMonthSelection>
    ) {
        self.id = id
        self.groupID = groupID
        self.date = date
        self.content = content
        self.incomeText = incomeText
        self.outgoText = outgoText
        self.category = category
        self.priorityText = priorityText
        self.repeatMonthSelections = repeatMonthSelections
        self.isRepeatEnabled = repeatMonthSelections.count > 1
    }
}
