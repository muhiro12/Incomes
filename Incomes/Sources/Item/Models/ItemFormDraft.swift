import Foundation

struct ItemFormDraft: Identifiable, Hashable {
    let id: UUID
    let groupID: UUID
    let date: Date
    let content: String
    let incomeText: String
    let outgoText: String
    let category: String
    let priorityText: String
    let repeatMonthSelections: Set<RepeatMonthSelection>
    let isRepeatEnabled: Bool

    init(
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
